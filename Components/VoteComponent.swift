//
//  VoteComponent.swift
//  RepNet
//
//  Created by Angel Bosquez on 12/10/25.
//
//componente para votar (upvote/downvote) en un reporte


import SwiftUI

struct VoteComponent: View {
    
    // un binding a la puntuacion total que se muestra en el centro.
    @Binding var score: Int
    
    // un binding al estado del voto del usuario actual (`.upvoted`, `.downvoted`, o `nil`).

    @Binding var voteStatus: UserVoteStatus?
    
    // el closure que se ejecuta cuando el usuario presiona el boton de upvote.
    let onUpvote: () -> Void
    
    // el closure que se ejecuta cuando el usuario presiona el boton de downvote.
    let onDownvote: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            // --- boton de upvote ---
            Button(action: onUpvote) {
                Image(systemName: "arrow.up")
                    .font(.title2)
                    // el color de la flecha cambia a azul si el voto actual es `upvoted`.
                    .foregroundColor(voteStatus == .upvoted ? .primaryBlue : .textSecondary)
            }
            
            // --- contador de puntuacion ---
            // se usa la extension `.formattedk` para mostrar numeros grandes de forma compacta.
            Text(score.formattedK)
                .font(.title2)
                .fontWeight(.bold)
                // un ancho minimo para el texto evita que el diseno "salte" cuando el numero de digitos cambia.
                .frame(minWidth: 50)
            
            // --- boton de downvote ---
            Button(action: onDownvote) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    // el color de la flecha cambia a rojo si el voto actual es `downvoted`.
                    .foregroundColor(voteStatus == .downvoted ? .red : .textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        // le da al fondo la forma de capsula redondeada.
        .clipShape(Capsule())
    }
}

//preview ia

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
