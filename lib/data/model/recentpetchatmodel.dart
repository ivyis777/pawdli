class RecentPetChat {
  WithPet? withPet;
  String? lastMessage;
  String? timestamp;

  RecentPetChat({this.withPet, this.lastMessage, this.timestamp});

  RecentPetChat.fromJson(Map<String, dynamic> json) {
    withPet = json['with_pet'] != null
        ? new WithPet.fromJson(json['with_pet'])
        : null;
    lastMessage = json['last_message'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.withPet != null) {
      data['with_pet'] = this.withPet!.toJson();
    }
    data['last_message'] = this.lastMessage;
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class WithPet {
  int? petId;
  String? name;
  String? petProfileImage;

  WithPet({this.petId, this.name, this.petProfileImage});

  WithPet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    name = json['name'];
    petProfileImage = json['pet_profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pet_id'] = this.petId;
    data['name'] = this.name;
    data['pet_profile_image'] = this.petProfileImage;
    return data;
  }
}
