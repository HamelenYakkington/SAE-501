from ultralytics import YOLO
import torch

if __name__ == '__main__':
    model = YOLO("yolov8s.pt")

    # Test pour que le modèle utilise mon GPU
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model.to(device)  # Utilisation du GPU

    results = model.train(data="data.yaml", epochs=75, imgsz=640, device=device, patience=25)