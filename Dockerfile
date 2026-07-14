FROM runpod/worker-comfyui:main-base

RUN comfy-node-install comfyui_ipadapter_plus

RUN mkdir -p /comfyui/models/ipadapter && \
    (wget -q -O /comfyui/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors \
       https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors \
     || curl -fsSL -o /comfyui/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors \
       https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors)
