FROM runpod/worker-comfyui:main-base

# IP-Adapter nodes — character identity from reference sheets (masked per region).
RUN comfy-node-install comfyui_ipadapter_plus

# Impact Pack (FaceDetailer) + Impact Subpack (UltralyticsDetectorProvider).
# These are dependency-heavy and comfy-node-install half-applies them (the node
# then imports-fails at startup → "FaceDetailer not found"). Clone directly and
# install the Python deps explicitly so the nodes register cleanly.
RUN cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git && \
    pip install --no-cache-dir ultralytics segment-anything dill piexif scikit-image opencv-python-headless && \
    (pip install --no-cache-dir -r ComfyUI-Impact-Pack/requirements.txt || true) && \
    (pip install --no-cache-dir -r ComfyUI-Impact-Subpack/requirements.txt || true)

# Models that live in NON-standard ComfyUI folders — the worker only auto-wires
# standard volume folders (checkpoints, loras, controlnet, clip_vision, vae),
# so these two get baked where their nodes look:
#   models/ipadapter    → IP-Adapter weights (IPAdapterUnifiedLoader)
#   models/ultralytics  → face detector (UltralyticsDetectorProvider)
RUN mkdir -p /comfyui/models/ipadapter /comfyui/models/ultralytics/bbox && \
    (wget -q -O /comfyui/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors \
       https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors \
     || curl -fsSL -o /comfyui/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors \
       https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors) && \
    (wget -q -O /comfyui/models/ultralytics/bbox/face_yolov8m.pt \
       https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt \
     || curl -fsSL -o /comfyui/models/ultralytics/bbox/face_yolov8m.pt \
       https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt)
