class ImageInfo {
	var id: String
	var localPath: String
}

class TripEntry {
	var id: String
	var text: String
	var images: [ImageInfo]
}

class Trip {
	func addEntry(entry: Entry)
	var entries: [TripEntry]
	var entriesToSync: [TripEntry]
}

class TripManager {
	func addTrip(name: String)
}
