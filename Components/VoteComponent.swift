//
//  VoteComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//
//componente para votar (upvote/downvote) en un reporte

import SwiftUI


struct VoteComponent: View {
    
    @Binding var score: Int
    
    // binding al estado del voto del usuario actual (.upvoted, .downvoted, o nil)
    @Binding var voteStatus: UserVoteStatus?
    
    let onUpvote: () -> Void
    
    let onDownvote: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onUpvote) {
                Image(systemName: "arrow.up")
                    .font(.title2)
                    .foregroundColor(voteStatus == .upvoted ? .primaryBlue : .textSecondary)
            }
            
      
            // se usa la extension .formattedk para mostrar numeros grandes
            Text(score.formattedK)
                .font(.title2)
                .fontWeight(.bold)
                .frame(minWidth: 50)
            
            Button(action: onDownvote) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundColor(voteStatus == .downvoted ? .red : .textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

//
// preview hecha con ia
struct VoteComponent_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var score = 566
        @State var status: UserVoteStatus? = .upvoted
        
        @State var score2 = -12
        @State var status2: UserVoteStatus? = .downvoted
        
        @State var score3 = 25
        @State var status3: UserVoteStatus? = nil
        
        var body: some View {
            VStack(spacing: 30) {
                Text("estado: upvoted").font(.caption)
                VoteComponent(score: $score, voteStatus: $status, onUpvote: {}, onDownvote: {})
                
                Text("estado: downvoted").font(.caption)
                VoteComponent(score: $score2, voteStatus: $status2, onUpvote: {}, onDownvote: {})
                
                Text("estado: neutral").font(.caption)
                VoteComponent(score: $score3, voteStatus: $status3, onUpvote: {}, onDownvote: {})
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
