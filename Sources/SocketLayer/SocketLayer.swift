import Foundation
import SignalRClient

public protocol Socket: class {
    
    func connect()
    func disconnect()
    func sendMessage(_ data: Data)
}

public protocol SocketDelegate: class {
    
    func didConnect()
    func didDisconnect()
    func didReceiveError(_ error: Error)
    func didReceiveMessage(_ data: Data)
}


public final class SignalRSocket {
    
    private var connection: Connection?
    private weak var delegate: SocketDelegate?
    
    public init(_ url: URL, delegate: SocketDelegate) {
        self.delegate = delegate
        
        setup(url)
    }
    
    
    private func setup(_ url: URL) {
        
        connection = HttpConnection(url: url)
        connection?.delegate = self
    }
}


// MARK: - Socket

extension SignalRSocket: Socket {
    
    public func connect() {
        
        connection?.start()
    }
    
    public func disconnect() {
        
        connection?.stop(stopError: nil)
    }
    
    public func sendMessage(_ data: Data) {
        
        connection?.send(data: data) {
            if let error = $0 {
                delegate?.didReceiveError(error)
            }
        }
    }
}


// MARK: - ConnectionDelegate

extension SignalRSocket: ConnectionDelegate {
    
    public func connectionDidOpen(connection: Connection) {
        
        delegate?.didConnect()
    }
    
    public func connectionDidFailToOpen(error: Error) {
        
        delegate?.didReceiveError(error)
    }
    
    public func connectionDidReceiveData(connection: Connection, data: Data) {
        
        delegate?.didReceiveMessage(data)
    }
    
    public func connectionDidClose(error: Error?) {
        
        if let error = error {
            delegate?.didReceiveError(error)
        } else {
            delegate?.didDisconnect()
        }
    }
}
