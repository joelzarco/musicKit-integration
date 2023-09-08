//
//  ContentView.swift
//  musicKitTest1
//
//  Created by sergio joel camacho zarco on 07/09/23.
//

import SwiftUI
import MusicKit

struct Item: Identifiable, Hashable{
    var id = UUID()
    let name : String
    let artist : String
    let imageUrl : URL?
}
/// remeber to register permission on info plist:
/// Privacy- Media liibrary usage description

// follow next steps to registr appId with music services
// https://developer.apple.com/documentation/musickit/using-automatic-token-generation-for-apple-music-api
struct ContentView: View {
    @State var songs = [Item]()
    
    var body: some View {
        NavigationStack{
            List(songs) { song in
                HStack{
                    AsyncImage(url: song.imageUrl)
                        .frame(width: 75, height: 75)
                    VStack{
                        Text(song.name)
                            .font(.title2)
                        Text(song.artist)
                            .font(.body)
                    }
                }
            } //ls
        } // nv
        .onAppear{
            fetchMusic()
        }
    }
    private let request : MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(term: "Shy away", types: [Song.self]) // several types to choose from, like playlists
        request.limit = 10
        return request
    }()
    
    private func fetchMusic(){
        Task{
            // request permission
            let status = await MusicAuthorization.request()
            switch status{
            case .authorized:
                // make request to musicApi
                do{
                    let result = try await request.response()
                    self.songs = result.songs.compactMap({ return .init(name: $0.title, artist: $0.artistName, imageUrl: $0.artwork?.url(width: 75, height: 75))})
                    print(songs.first?.name)
                }
                catch{
                    print(String(describing: error))
                }
                    // assign songs
            case .denied:
                print("Permission denied")
            case .notDetermined:
                print("User has yet to decide")
            case .restricted:
                print("Restricted mode on device")
            default:
                break
            }
            
        } //tsk
    } // fetch
}
