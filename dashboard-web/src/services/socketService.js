import { io } from 'socket.io-client';

const URL = 'http://localhost:3000'; // Your backend URL

class SocketService {
  socket;

  connect() {
    // Prevent multiple connections
    if (!this.socket || !this.socket.connected) {
      this.socket = io(URL);
      console.log('Connecting to WebSocket server...');

      this.socket.on('connect', () => {
        console.log('Successfully connected to WebSocket server with ID:', this.socket.id);
      });
    }
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      console.log('Disconnected from WebSocket server.');
    }
  }

  on(eventName, callback) {
    if (this.socket) {
      this.socket.on(eventName, callback);
    }
  }

  emit(eventName, data) {
    if (this.socket) {
      this.socket.emit(eventName, data);
    }
  }

  leaveRoom(roomName) {
    if (this.socket) {
      this.socket.leave(roomName);
    }
  }
}

const socketService = new SocketService();
export default socketService;