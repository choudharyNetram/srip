# Real-Time Assistive Typing Mobile Application with CNN and OpenCV-Enhanced Server

This project implements a real-time typing application using Flutter for the frontend and a Python backend powered by Flask and various libraries. It leverages CNNs (Convolutional Neural Networks) for prediction and OpenCV for image processing, enabling an efficient and accurate user experience.

**Key Features:**

* Real-time typing with high prediction accuracy
* User-friendly virtual keyboard interface
* Calibration window for personalized model fine-tuning
* Efficient communication between frontend and backend using SocketIO

**Tech Stack:**

* **Frontend (Flutter):**
    * Cross-platform development for consistent user experience across devices
    * Virtual keyboard for real-time interaction
    * Calibration Window for Fine-tuning of model
    * Communication with backend server through SocketIO
* **Backend (Python):**
    * Flask for lightweight and efficient web framework
    * OpenCV for image processing tasks like face and eye detection
    * NumPy for numerical computations
    * TensorFlow for machine learning model implementation (CNN)
    * Pillow for image manipulation
    * Scikit-learn for machine learning utilities 
    * Keras for deep learning 
    * Eventlet for asynchronous task handling 

**Installation:**

**1. Python Backend:**

## Installation (Python Backend)

You'll need the following Python libraries for the backend server:

```bash
pip install Flask Flask-SocketIO opencv-python numpy tensorflow Pillow matplotlib pandas scikit-learn keras eventlet
```

**2. Flutter Frontend:**

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  camera: ^0.11.0+2
  flutter:
    sdk: flutter
  provider: ^6.0.0
  path_provider: ^2.1.3
  image_picker: ^1.1.1
  image: ^4.2.0
  socket_io_client: ^2.0.3+1
```
Then Run: 
flutter pub get


