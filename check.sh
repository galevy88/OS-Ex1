export player1_guess=0
export player2_guess=0


print_players_guess() {
  echo "       Player 1 played: $player1_guess"
  echo "       Player 2 played: $player2_guess"
}


play_one_turn() {
    echo "PLAYER 1 PICK A NUMBER: " >&2
    read guess1
    
    echo "PLAYER 2 PICK A NUMBER: " >&2
    read guess2

    player1_guess=$guess1
    player2_guess=$guess2
}

  echo "$player1_guess $player2_guess"
  play_one_turn
  print_players_guess