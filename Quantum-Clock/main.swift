//
//  main.swift
//  Quantum-Clock
//
//  Created by AdvocatesClose on 12/9/24.
//

import Foundation
import Metal

func main() {
		// Initialize Metal
	guard let device = MTLCreateSystemDefaultDevice() else {
		fatalError("Metal is not supported on this device.")
	}

	let quantumClock = QuantumClock(device: device)

		// Simulate 4 ticks of the quantum clock
	for tick in 1...4 {
		quantumClock.tick()
		let state = quantumClock.getState()
		print("Tick \(tick): |0⟩ = \(state.state.0), |1⟩ = \(state.state.1)")
	}
}

	// Run the main function
main()
