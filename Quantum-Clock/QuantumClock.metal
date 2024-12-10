//
//  QuantumClock.metal
//  Quantum-Clock
//
//  Created by AdvocatesClose on 12/9/24.
//

#include <metal_stdlib>
using namespace metal;

	// Structure for passing data to the GPU
struct QuantumState {
	float state[2];  // Simulating |0⟩ and |1⟩ amplitudes
};

	// Kernel function to simulate a clock tick (Rz rotation)
kernel void quantumClockTick(device QuantumState *state [[buffer(0)]],
							 constant float &angle [[buffer(1)]],
							 uint id [[thread_position_in_grid]]) {
		// Rotation matrix for Rz gate
	float cosTheta = cos(angle);
	float sinTheta = sin(angle);

		// Apply rotation to the quantum state
	float newState0 = cosTheta * state[id].state[0] - sinTheta * state[id].state[1];
	float newState1 = sinTheta * state[id].state[0] + cosTheta * state[id].state[1];

	state[id].state[0] = newState0;
	state[id].state[1] = newState1;
}
