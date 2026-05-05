#!/usr/bin/env python3
"""
Train a Plant Disease Image Classifier and export to CoreML (.mlmodel)

SETUP:
  pip install torch torchvision coremltools Pillow

DATASET:
  Download PlantVillage dataset from Kaggle:
  https://www.kaggle.com/datasets/emmarex/plantdisease
  
  Extract so the folder structure is:
    dataset/
      train/
        Tomato___Leaf_Blight/
        Tomato___healthy/
        Potato___Early_blight/
        ...
      val/
        (same subfolders)

USAGE:
  python train_leaf_model.py --data ./dataset --epochs 10 --output LeafDisease.mlmodel

Then drag LeafDisease.mlmodel into your Xcode project.
"""

import argparse
import torch
import torch.nn as nn
import torchvision.transforms as transforms
import torchvision.datasets as datasets
import torchvision.models as models
from torch.utils.data import DataLoader
import coremltools as ct

def train(data_dir, epochs, output_path):
    transform_train = transforms.Compose([
        transforms.RandomResizedCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    transform_val = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    train_dataset = datasets.ImageFolder(f"{data_dir}/train", transform=transform_train)
    val_dataset = datasets.ImageFolder(f"{data_dir}/val", transform=transform_val)

    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True, num_workers=4)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=4)

    class_names = train_dataset.classes
    num_classes = len(class_names)
    print(f"Found {num_classes} classes: {class_names}")

    # Use MobileNetV2 for mobile-friendly size
    model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)
    model.classifier[1] = nn.Linear(model.last_channel, num_classes)

    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    model = model.to(device)

    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=3, gamma=0.1)

    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0

        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item()
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()

        scheduler.step()
        train_acc = 100.0 * correct / total

        # Validation
        model.eval()
        val_correct = 0
        val_total = 0
        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                _, predicted = outputs.max(1)
                val_total += labels.size(0)
                val_correct += predicted.eq(labels).sum().item()

        val_acc = 100.0 * val_correct / val_total
        print(f"Epoch {epoch+1}/{epochs} - Loss: {running_loss/len(train_loader):.4f} - "
              f"Train Acc: {train_acc:.1f}% - Val Acc: {val_acc:.1f}%")

    # Export to CoreML
    model.eval()
    model = model.to("cpu")
    example_input = torch.rand(1, 3, 224, 224)
    traced = torch.jit.trace(model, example_input)

    mlmodel = ct.convert(
        traced,
        inputs=[ct.ImageType(name="image", shape=(1, 3, 224, 224),
                             scale=1/255.0, bias=[-0.485/0.229, -0.456/0.224, -0.406/0.225])],
        classifier_config=ct.ClassifierConfig(class_names),
    )
    mlmodel.save(output_path)
    print(f"\nModel saved to {output_path}")
    print(f"Drag this file into your Xcode project to enable ML-powered leaf scanning!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True, help="Path to dataset folder")
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--output", default="LeafDisease.mlmodel")
    args = parser.parse_args()
    train(args.data, args.epochs, args.output)
