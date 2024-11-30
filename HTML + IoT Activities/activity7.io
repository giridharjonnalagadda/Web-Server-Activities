How can I use an ESP32 microcontroller to control an LED through a web interface using Wi-Fi, and what is the process to toggle the LED state via HTTP requests?

#include <WiFi.h>
#include <WebServer.h>

// Replace with your Wi-Fi credentials
const char* ssid = "Act";
const char* password = "Madhumakeskilled";

// Create a web server object on port 80
WebServer server(80);

// Define the GPIO pin for the LED
const int ledPin = 2; // Change this to the pin connected to your LED

void setup() {
  pinMode(ledPin, OUTPUT); // Set the LED pin as an output
  digitalWrite(ledPin, LOW); // Turn off the LED initially

  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Serve the main HTML page
  server.on("/", HTTP_GET, []() {
    String html = "<html><head><style>";
    html += "body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }";
    html += "button { padding: 15px 30px; font-size: 1.5em; margin: 20px; border: none; border-radius: 5px; }";
    html += ".on { background-color: #27ae60; color: white; }";
    html += ".off { background-color: #c0392b; color: white; }";
    html += "</style></head><body>";
    html += "<h1>ESP32 LED Control</h1>";
    html += "<button class='on' onclick=\"fetch('/on')\">ON</button>";
    html += "<button class='off' onclick=\"fetch('/off')\">OFF</button>";
    html += "</body></html>";
    server.send(200, "text/html", html);
  });

  // Turn the LED ON
  server.on("/on", HTTP_GET, []() {
    digitalWrite(ledPin, HIGH); // Turn the LED on
    server.send(200, "text/plain", "LED is ON");
  });

  // Turn the LED OFF
  server.on("/off", HTTP_GET, []() {
    digitalWrite(ledPin, LOW); // Turn the LED off
    server.send(200, "text/plain", "LED is OFF");
  });

  // Start the server
  server.begin();
}

void loop() {
  server.handleClient(); // Handle incoming client requests
}
