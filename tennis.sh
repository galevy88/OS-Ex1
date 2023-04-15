#!/bin/bash

export ball_pos=0
export player1_points=50
export player2_points=50
export player1_guess=0
export player2_guess=0



print_open_board() {
    echo " --------------------------------- "
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    echo " |       |       O       |       | "
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    echo " --------------------------------- "
}

print_players_points() {
  echo " Player 1: ${player1_points}         Player 2: ${player2_points} "
}

print_players_guess() {
  echo "       Player 1 played: $player1_guess"
  echo "       Player 2 played: $player2_guess"
}

validate_guess() {
  local player_points=$1
  local guess=$2
  
  # Check if the guess is an integer
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "NOT A VALID MOVE !" >&2
    return 1
  fi
  
  # Check if the guess is less than or equal to the player's points
  if (( guess > player_points )); then
    echo "NOT A VALID MOVE !" >&2
    return 1
  fi
  
  return 0
}

play_one_turn() {
    echo "PLAYER 1 PICK A NUMBER: " >&2
    read -s guess1
    
    while ! validate_guess "$player1_points" "$guess1"; do
        echo "PLAYER 1 PICK A NUMBER: " >&2
        read -s guess1
    done
    
    echo "PLAYER 2 PICK A NUMBER: " >&2
    read -s guess2

    while ! validate_guess "$player2_points" "$guess2"; do
        echo "PLAYER 2 PICK A NUMBER: " >&2
        read -s guess2
    done

    player1_guess=$guess1
    player2_guess=$guess2

    player1_points=$((player1_points - guess1))
    player2_points=$((player2_points - guess2))

    if ((guess1 > guess2)); then
        winner=1
    elif ((guess1 < guess2)); then
        winner=2
    else
        winner=0
    fi
    
    echo "$player1_guess $player2_guess $player1_points $player2_points $winner"
}

print_board() {
    echo " --------------------------------- "
    echo " |       |       #       |       | "
    echo " |       |       #       |       | "

    case $1 in
        -3)
            echo "O|       |       #       |       | "
            ;;
        -2)
            echo " |   O   |       #       |       | "
            ;;
        -1)
            echo " |       |   O   #       |       | "
            ;;
        0)
            echo " |       |       O       |       | "
            ;;
        1)
            echo " |       |       #   O   |       | "
            ;;
        2)
            echo " |       |       #       |   O   | "
            ;;
        3)
            echo " |       |       #       |       |O"
            ;;
    esac

    echo " |       |       #       |       | "
    echo " |       |       #       |       | "
    echo " --------------------------------- "
}

determine_ball_pos() {
    local winner="$1"
    if (( winner == 0 )); then
        new_ball_pos=$ball_pos
    fi
    if (( ball_pos == 0 && winner == 1 )); then
        new_ball_pos=1
    fi
    if (( ball_pos == 0 && winner == 2 )); then
        new_ball_pos=-1
    fi

    if (( ball_pos == 1 && winner == 1 )); then
        new_ball_pos=2
    fi
    if (( ball_pos == 1 && winner == 2 )); then
        new_ball_pos=-1
    fi
    if (( ball_pos == -1 && winner == 2 )); then
        new_ball_pos=-2
    fi
    if (( ball_pos == -1 && winner == 1 )); then
        new_ball_pos=1
    fi
    
    if (( ball_pos == 2 && winner == 1 )); then
        new_ball_pos=3
    fi
    if (( ball_pos == 2 && winner == 2 )); then
        new_ball_pos=-1
    fi
    if (( ball_pos == -2 && winner == 2 )); then
        new_ball_pos=-3
    fi
    if (( ball_pos == -2 && winner == 1 )); then
        new_ball_pos=1
    fi

    echo "$new_ball_pos"
}




check_end_game() {
    local ball_pos="$1"
    local player1_points="$2"
    local player2_points="$3"

    if (( ball_pos == 3 )); then
         echo "PLAYER 1 WINS !"
    fi
    if (( ball_pos == -3 )); then
         echo "PLAYER 2 WINS !"
    fi

    if (( player2_points == 0 && player1_points > 0 )); then
        echo "PLAYER 1 WINS !"
    fi
    if (( player1_points == 0 && player2_points > 0 )); then
        echo "PLAYER 2 WINS !"
    fi

    if (( player1_points == 0 && player2_points == 0 && ball_pos > 0 )); then
        echo "PLAYER 1 WINS !"
    fi
    if ((  player1_points == 0 && player2_points == 0 && ball_pos < 0 )); then
        echo "PLAYER 2 WINS !"
    fi
    if ((  player1_points == 0 && player2_points == 0 && ball_pos == 0 )); then
        echo "IT'S A DRAW !"
    fi
}


print_open_board

game_over=0
while (( game_over == 0 )); do
    print_players_points
    result="$(play_one_turn)"
    read player1_guess player2_guess player1_points player2_points winner <<< "$result"
    ball_pos=$(determine_ball_pos "$winner")
    print_board $ball_pos
    cont=$(check_end_game "$ball_pos" "$player1_points" "$player2_points")
    if [[ $cont == 'PLAYER 1 WINS !' || $cont == 'PLAYER 2 WINS !' || $cont == 'IT'\''S A DRAW !' ]]; then
        echo $cont
        game_over=1
    else
        print_players_guess
    fi
done



