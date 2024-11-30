# How can I control a buzzer connected to an ESP32 using a web interface and provide feedback on the buzzer's status?

#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";

// Create a web server object on port 80
WebServer server(80);

// Define the GPIO pin for the buzzer
const int buzzerPin = 26;

// Initial buzzer state
bool isBuzzerOn = false;

void setup() {
  Serial.begin(115200);

  // Set buzzer pin as output
  pinMode(buzzerPin, OUTPUT);
  digitalWrite(buzzerPin, LOW);  // Ensure buzzer is off initially

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Handle root path (main HTML page)
  server.on("/", HTTP_GET, []() {
    String html = "<html><head>";
    html += "<style>";
    html += "body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f4f6f9;}";
    html += "button { font-size: 20px; padding: 10px 20px; margin: 20px; border: none; border-radius: 5px; cursor: pointer; }";
    html += ".on { background-color: #27ae60; color: white; }";
    html += ".off { background-color: #c0392b; color: white; }";
    html += "</style>";
    html += "</head><body>";
    html += "<h1>ESP32 Buzzer Control</h1>";
    html += "<button class='on' onclick='toggleBuzzer(\"on\")'>Turn ON</button>";
    html += "<button class='off' onclick='toggleBuzzer(\"off\")'>Turn OFF</button>";
    html += "<script>";
    html += "function toggleBuzzer(state) {";
    html += "  fetch('/buzzer?state=' + state).then(response => response.text()).then(data => {";
    html += "    alert(data);";
    html += "  });";
    html += "}";
    html += "</script>";
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Handle buzzer toggle requests
  server.on("/buzzer", HTTP_GET, []() {
    if (server.hasArg("state")) {
      String state = server.arg("state");
      if (state == "on") {
        digitalWrite(buzzerPin, HIGH);  // Turn on buzzer
        isBuzzerOn = true;
        server.send(200, "text/plain", "Buzzer is ON");
      } else if (state == "off") {
        digitalWrite(buzzerPin, LOW);  // Turn off buzzer
        isBuzzerOn = false;
        server.send(200, "text/plain", "Buzzer is OFF");
      } else {
        server.send(400, "text/plain", "Invalid state");
      }
    } else {
      server.send(400, "text/plain", "State not provided");
    }
  });

  // Start the server
  server.begin();
}

void loop() {
  server.handleClient();  // Handle client requests
}
