//
//  QuantumClock.swift
//  Quantum-Clock
//
//  Created by AdvocatesClose on 12/9/24.
//

import MetalKit

	// Define a structure matching the Metal shader structure
struct QuantumState {
	var state: (Float, Float)  // |0⟩ and |1⟩ amplitudes
}

class QuantumClock {
	private let device: MTLDevice
	private let queue: MTLCommandQueue
	private let pipeline: MTLComputePipelineState

	private var stateBuffer: MTLBuffer
	private var angleBuffer: MTLBuffer
	private var tickAngle: Float

	init(device: MTLDevice, tickAngle: Float = Float.pi / 4) {
		self.device = device
		self.queue = device.makeCommandQueue()!

			// Load the Metal shader function
		let library = device.makeDefaultLibrary()!
		let function = library.makeFunction(name: "quantumClockTick")!
		self.pipeline = try! device.makeComputePipelineState(function: function)

			// Initialize quantum state buffer
		let initialState = QuantumState(state: (1.0, 0.0))  // Start in |0⟩
		self.stateBuffer = device.makeBuffer(bytes: [initialState],
											 length: MemoryLayout<QuantumState>.stride,
											 options: .storageModeShared)!

			// Initialize angle buffer
		self.tickAngle = tickAngle
		self.angleBuffer = device.makeBuffer(bytes: &self.tickAngle,
											 length: MemoryLayout<Float>.stride,
											 options: .storageModeShared)!
	}

	func tick() {
			// Create a command buffer and encode the compute kernel
		guard let commandBuffer = queue.makeCommandBuffer(),
			  let encoder = commandBuffer.makeComputeCommandEncoder() else {
			return
		}

		encoder.setComputePipelineState(pipeline)
		encoder.setBuffer(stateBuffer, offset: 0, index: 0)
		encoder.setBuffer(angleBuffer, offset: 0, index: 1)

			// Dispatch compute threads
		let threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
		let threadGroups = MTLSize(width: 1, height: 1, depth: 1)
		encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
		encoder.endEncoding()

			// Commit the command buffer
		commandBuffer.commit()
		commandBuffer.waitUntilCompleted()
	}

	func getState() -> QuantumState {
			// Access the updated state from the buffer
		let pointer = stateBuffer.contents().bindMemory(to: QuantumState.self, capacity: 1)
		return pointer.pointee
	}
}

	// Main function to demonstrate the quantum clock
