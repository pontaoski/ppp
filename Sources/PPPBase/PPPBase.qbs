Library {
	name: "PPPBase"

	files: [
		"*.mm",
		"*.h",
	]

	Export {
		cpp.includePaths: exportingProduct.sourceDirectory
		cpp.dynamicLibraries: ["gnustep-base", "objc"]
		cpp.objcxxFlags: ["-fconstant-string-class=NSConstantString", "-fobjc-runtime=gnustep-2.0", "-fobjc-arc", "-fcoroutines-ts"]
		cpp.rpaths: exportingProduct.buildDirectory

		Depends { name: "gdk-3.0" }
		Depends { name: "glib-2.0" }
		Depends { name: "cairomm-1.0" }
		Depends { name: "cpp" }
	}

	cpp.dynamicLibraries: ["gnustep-base", "objc"]
	cpp.objcxxFlags: ["-fconstant-string-class=NSConstantString", "-fobjc-runtime=gnustep-2.0", "-fobjc-arc", "-fcoroutines-ts"]
	cpp.rpaths: cpp.buildDirectory

	Depends { name: "gdk-3.0" }
	Depends { name: "glib-2.0" }
	Depends { name: "cairomm-1.0" }
	Depends { name: "cpp" }
}
