// GameSpot is a Website which is intended to sell Video Games online
//E/18/118 
import ballerina/http;

type VideoGame record {|
    readonly string id;
    string name;
    string available_quantity;
    string price;
    string category;
    string console;
|};

type Invoice record {|
    readonly string invoice_id;
    string customer_id;
    string amount;
    string created_date;
    string details;
|};

service /gameSpot on new http:Listener(9090) {

// Get All Video Games to Show in the Home Page of the Video Game Website
    resource function get getAllvideoGames() returns VideoGame[]|error {
        return videoGames.toArray();
    }

// Sellers Can Add a new Video Game to the Website
    resource function post addVideoGame(@http:Payload VideoGame videoGame) returns VideoGame|ConflictingRecordError {
        if videoGames.hasKey(videoGame.id) {
            return {
                body: {
                    errmsg: "VideoGame Already Exists"
                }
            };
        }
        videoGames.add(videoGame);
        return videoGame;
    }

// Sellers Can Edit Existing Video Game in the Website
    resource function put editVideoGame(@http:Payload VideoGame videoGame) returns VideoGame|InvalidIDError {
        VideoGame? videoGame_record = videoGames[videoGame.id];

        if videoGame_record is () {
            return {
                body: {
                    errmsg: "VideoGame record not found. Invalid ID"
                }
            };
        }

        videoGame_record.name = videoGame.name;
        videoGame_record.available_quantity = videoGame.available_quantity;
        videoGame_record.price = videoGame.price;
        videoGame_record.category = videoGame.category;
        videoGame_record.console = videoGame.console;

        return videoGame;
    }

// Sellers Can Delete a Video Game in the Website (Eg: When Inventory is Empty)
    resource function delete deleteVideoGame/[string id]() returns string|InvalidIDError {
        if videoGames.hasKey(id) {
            _ = videoGames.remove(id);
            return "Video Game Item Deleted Successfully";
        }
        else {
            return {
                    body: {
                        errmsg: "VideoGame record not found. Invalid ID"
                    }
            };
        }
    }
}

table<VideoGame> key(id) videoGames = table [
    {id: "1", name: "Fifa 14", available_quantity: "10"
    , price: "12.99", category: "Sports", console: "ps4"},

    {id: "2", name: "Crysis 3", available_quantity: "20"
    , price: "8.99", category: "Shooting", console: "ps4"},

    {id: "3", name: "Drift 3", available_quantity: "15"
    , price: "8.99", category: "Razing", console: "xbox"}
];

public type ConflictingRecordError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidIDError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};