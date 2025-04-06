# GrowCode - One-Stop Solution for Agriculture Landscape

![GrowCode Logo](assets/images/logo.jpg)

## Overview

**GrowCode** integrates a mobile app and IoT device to provide farmers with a unified platform, offering marketplace linkages and real-time analytics on weather and soil health. Employing a data-driven approach, it delivers personalized insights on plant and soil health monitoring, yield enhancement, and sustainable practices. The Android app serves as a comprehensive solution transforming the farming experience through streamlined features. 🌾🚀

## 📱 In-App Features 🌟🔧

- **Secured Authentication:** Prioritizing privacy and security with OTP authentication. 🔒

- **Multilingual Support:** Choose your preferred language; presently, English is supported. 🌐

- **User Role Specification:** Tailoring functionalities for each user type (farmer, customer, seller) to ensure a personalized and seamless experience. 🌱

### Farming Assistance

- **AgroGuide:** Harness the power of ML for crop prediction, recommendations, and IOT crop monitoring. 🌱🤖

- **Weather Forecasts:** Receive hyperlocal weather forecasts and advisories. 🌦️⚠️

- **Buy & Rent:** Seamlessly access farming equipment and essentials. 🛒

### 🤖 Support 🤖

- **In-app Chatbot:** Instant customer support and farming guidance bot. 🤖💬

## Important Links

- [APK](https://drive.google.com/drive/folders/10PXVfk7SEJDg5w0RjuILpRPFm8IJsi2i?usp=drive_link)

## 💻 Tech Stack 🔧

- Flutter  
- Google AI Studio  
- Google Teachable Machine  
- Vertex AI  
- Gemini API  
- Weather API  
- Firebase (Authentication, Firestore, Cloud Messaging)

## ✨ Requirements

* Any Operating System (ie. MacOS X, Linux, Windows)  
* Any IDE with Flutter SDK installed (ie. IntelliJ, Android Studio, VSCode etc)  
* A little knowledge of Dart and Flutter  

## 🚀 Steps to Run the Application 🛠️

- Clone the GitHub Repository:

  ```bash
  git clone https://github.com/BadassAman4014/GrowwCode.git
  ```

- Navigate to the Project Directory:

  ```bash
  cd Farmily-revised
  ```

- Get Dependencies:

  ```bash
  flutter pub get
  ```

- Get the suitable version of tflite to run the app:

  Replace these lines in the tflite package `build.gradle` file  
  Example location:  
  `C:\Users\"username"\AppData\Local\Pub\Cache\hosted\pub.dev\tflite-1.1.2\android\build.gradle`

  ```groovy
  implementation 'org.tensorflow:tensorflow-lite:2.0.0'
  implementation 'org.tensorflow:tensorflow-lite-gpu:2.0.0'
  ```

  After replacing, it should look like:

  ```groovy
  android {
    compileSdkVersion 28

    defaultConfig {
        minSdkVersion 19
        testInstrumentationRunner 'androidx.test.runner.AndroidJUnitRunner'
    }
    lintOptions {
        disable 'InvalidPackage'
    }

    dependencies {
        implementation 'org.tensorflow:tensorflow-lite:2.0.0'
        implementation 'org.tensorflow:tensorflow-lite-gpu:2.0.0'
    }
  }
  ```

- Run install.bat

  ```bash
  install.bat
  ```

- Run the Flutter application

  ```bash
  flutter run
  ```

## Usage

Explore the robust features of GrowCode to streamline your agricultural activities and make informed decisions. The app provides timely weather insights, enabling farmers to prepare for climate extremes. Data-driven crop rotation suggestions and soil health monitoring enhance productivity. Equipment renting options and a direct marketplace streamline harvest sales, eliminating intermediaries. The app predicts and offers cures for plant diseases, provides a chatbot for farming guidance, and shares the latest farming news, ensuring farmers stay informed. GrowCode empowers farmers with technology and knowledge, fostering sustainability, and improved livelihoods.🌾📊

## Future Outlook

### 🌾 Crop Prediction Feature Enhancements 📈🌱

We're incorporating IOT for improved crop prediction in our pursuit of precision. Superior sensors will keep an eye on soil conditions, encouraging healthy development and increased yields. 💡🌱🚜

- Temperature  
- Humidity  
- Soil pH  
- Rainfall

This data will be seamlessly sent to a real-time database, empowering our Google Colab ML model to predict crop yields and quality. 🌾📈

### 📊 Seller Dashboard 📈

We're crafting a comprehensive dashboard for sellers/farmers to analyze and monitor:  
- Sales  
- Crop yield tracking  
- Revenue  

Empower yourself with data-driven insights to optimize production and skyrocket profits. 💹📊

### 🌾 AgroHire: Labor Portal 🤝💼

We are working on developing a labor portal so that farmers can easily connect with available labor during crucial agricultural cycles, ensuring workforce availability for tasks like sowing, harvesting, and other key agricultural activities. 🧑‍🌾👩‍🌾

## 👥 Our Members 🌐

- Valhari Meshram  
- Aman Raut  
- Viranchi Dakhare

### Contributors

Join us in cultivating innovation in Indian agriculture. Your contributions are the seeds of change! 🌱🤝
