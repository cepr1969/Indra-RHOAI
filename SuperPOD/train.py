from torchvision import transforms
from torchvision.datasets import MNIST
from torch.utils.data import DataLoader
import pytorch_lightning as L
from pathlib import Path
from model import LitAutoEncoder, Encoder, Decoder


def main():
    # Configuration
    DATASET_PATH = Path(__file__).parent.resolve() / "data"

    # Data loading
    dataset = MNIST(root=str(DATASET_PATH.absolute()))
    train_loader = DataLoader(dataset)

    # Model loading
    autoencoder = LitAutoEncoder(Encoder(), Decoder())

    # Model training
    trainer = L.Trainer()
    trainer.fit(model=autoencoder, train_dataloaders=train_loader)


if __name__ == "__main__":
    main()
