# Variables
BINARY_NAME = ical2json
SOURCE_FILE = ical2json.swift
INTEL_BINARY = $(BINARY_NAME)_x86_64
ARM_BINARY = $(BINARY_NAME)_arm64

# Build release version (universal binary)
build-release: $(BINARY_NAME)

# Create Intel binary
$(INTEL_BINARY): $(SOURCE_FILE)
	xcrun --sdk macosx swiftc -target x86_64-apple-macos10.15 -O -whole-module-optimization -o $(INTEL_BINARY) $(SOURCE_FILE)

# Create ARM binary
$(ARM_BINARY): $(SOURCE_FILE)
	xcrun --sdk macosx swiftc -target arm64-apple-macos11 -O -whole-module-optimization -o $(ARM_BINARY) $(SOURCE_FILE)

# Create universal binary
$(BINARY_NAME): $(INTEL_BINARY) $(ARM_BINARY)
	lipo -create $(INTEL_BINARY) $(ARM_BINARY) -output $(BINARY_NAME)
	chmod +x $(BINARY_NAME)
	rm -f $(INTEL_BINARY) $(ARM_BINARY)

# Clean all build files
clean:
	rm -f $(INTEL_BINARY) $(ARM_BINARY) $(BINARY_NAME)

.PHONY: build-release clean