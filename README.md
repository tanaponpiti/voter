# Voter App - Backend Setup

This guide will help you set up the Voter App Backend using Docker Compose. The setup includes a `voter_server` service and a `mongodb` service.

## Prerequisites

Before you begin, ensure you have the following installed:

- Docker: [Get Docker](https://docs.docker.com/get-docker/)
- Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)

## Configuration

The `docker-compose.yml` file is pre-configured with the necessary environment variables and settings. Here's a quick overview of the services:

- **voter_server**: The main application server.
  - Image: `ghcr.io/tanaponpiti/voter:latest-amd64`
  - Port: `8080`
 
An image ghcr.io/tanaponpiti/voter:latest contains latest version of builded docker image of backend source code in voter_server directory. There are 2 versions of it 
- ghcr.io/tanaponpiti/voter:latest-arm64 for running in Apple Silicon like (M1) 
- ghcr.io/tanaponpiti/voter:latest-amd64 for running in linux and other envionment
  
if none of it works on you system feel free to build image using voter_server/Dockerfile 

- **mongodb**: The MongoDB database server.
  - Image: `mongo:6.0.13`
  - Port: `27017`

The application's configuration is done through environment variables within the `docker-compose.yml` file. Ensure the values, especially for secrets and passwords, are secure and appropriate for your environment.

## Steps to Run

1. **Clone the Repository (Optional)**: If the `docker-compose.yml` is part of a repository, clone it first. Otherwise, ensure you have the `docker-compose.yml` file in your working directory.

    ```sh
    git clone https://github.com/tanaponpiti/voter.git
    cd voter
    ```

2. **Start the Services**:

    Run the following command in the directory where your `docker-compose.yml` is located:

    ```sh
    docker-compose up -d
    ```

    This command will start the services in detached mode. The `-d` flag means that Docker will run your services in the background.

3. **Verify the Services**:

    To check if the services are running correctly, use:

    ```sh
    docker-compose ps
    ```

    This command shows the status of the running services. Ensure that the `voter_server` and `mongodb` services are up and running.

4. **Access the Application**:

    The voter application should now be accessible through your browser or API client at:

    ```
    http://localhost:8080/app
    ```
    You will found web client version of voter app inside this path. However, this app was written in Flutter so using it on mobile device (iOS,Android) is more desirable. Observer next section to learn how to build and run them in next section.


5. **View Logs**:

    If you need to troubleshoot or monitor the application, you can view the logs using:

    ```sh
    docker-compose logs
    ```

    Add the `-f` flag to follow the log output (live tail).

6. **Stop the Services**:

    When you're done, you can stop the services using:

    ```sh
    docker-compose down
    ```

    To also remove the volumes and clean up data, use:

    ```sh
    docker-compose down -v
    ```

## Data Persistence

The MongoDB data is persisted in a Docker volume (`voter_mongodb_data`). This means your data remains intact across container restarts. If you need to reset the data, you can remove the volume using Docker's volume commands.

## Test Users

Upon starting the service, the system will automatically create test users for you to use. The usernames are as follows:

- testuser1
- testuser2
- testuser3
- testuser4
- testuser5
- testuser6
- testuser7
- testuser8
- testuser9
- testuser10

All test users have the same password: `testpassword`.


## Security Notice

The `docker-compose.yml` file contains sensitive information, including secrets and passwords. Ensure this file is adequately protected, and do not expose it in public repositories or insecure places.

---

# Building the Frontend Voter App (iOS and Android)

The `voter_app` directory contains the source code for the Flutter frontend client app. Follow the instructions below to build and run the client app on iOS and Android devices.

## Prerequisites

- Flutter: Ensure that you have Flutter installed on your system. If not, you can download and install it from the [Flutter official website](https://flutter.dev/docs/get-started/install).
- IDE: You can use an IDE like Android Studio or Visual Studio Code with Flutter and Dart plugins installed.
- Xcode: For building iOS applications, ensure you have Xcode installed.
- Android Studio: For building Android applications, ensure you have Android Studio and the Android SDK installed.

## Steps to Build and Run

1. **Get the Code**:
   
   Ensure you are in the root directory of the cloned repository and navigate to the `voter_app` directory:

   ```sh
   cd voter_app

   ```

2. **Install Dependencies**:
   
   Run the following command to fetch and install all the required packages and dependencies:
   ```sh
   flutter pub get

   ```
  
3. **Build and Run**:

   Open the iOS Simulator or Android Emulator
   Run the following command to build and run image on emulator:
   ```sh
   flutter run

   ```
---
## Configuring API Constants (Optional)

If you need to connect the Flutter client app to a different backend server or if you're running the app on an emulator and need to connect to a local server, you may need to modify the API constants.

The API constants are located in the `voter_app/lib/config/api_constant.dart` file. Here's the content of the file for reference:

```dart
class APIConstants {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String userDataEndpoint = '/auth/me';
  static const String voteEndpoint = '/vote';
  static const String userVoteEndpoint = '/vote/user';
}
```

### Changing the Base URL

You might need to change the `baseUrl` if your backend server is running on a different IP or if you are using an Android emulator and need to connect to the local server. Here's how you can do it:

1. **Open the `api_constant.dart` File**:
   
   Navigate to `voter_app/lib/config/` and open the `api_constant.dart` file in your preferred code editor.

2. **Modify the `baseUrl` Constant**:
   
   Change the `baseUrl` from the default `http://localhost:8080/api` to the IP of your backend server. For example, if you're using an Android emulator, you might need to change it to:

   ```dart
   static const String baseUrl = 'http://10.0.2.2:8080/api';
   ```

   This IP (`10.0.2.2`) is used to connect to the local server from the Android emulator.

3. **Save the Changes**:
   
   After making the changes, save the file.

4. **Rebuild the App**:
   
   Rebuild your Flutter app to ensure that the changes take effect.

   ```sh
   flutter run
   ```

### Notes

- Remember to use the correct IP and port number that match your backend server configuration.
- If you're testing the app on a real device, ensure that the device is on the same network as your backend server and use the server's IP address in the network.
- Changing the `baseUrl` might affect all the endpoints in the `APIConstants` class, so ensure that the rest of the endpoints are correctly configured relative to your `baseUrl`.

---
Make sure to test the connectivity after changing the `baseUrl` to ensure that the app can communicate with your backend server successfully.

---
If you encounter any issues or have questions, you can contact me directly at [perthpiti@gmail.com](mailto:perthpiti@gmail.com)
