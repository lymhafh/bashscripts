#!/bin/bash

COLOR(){
    echo -e "\e[0;$2m$1\e[0m"
}

RED(){
    echo $(COLOR "$1" "31")
}

GREEN(){
    echo $(COLOR "$1" "32")
}

YELLOW(){
    echo $(COLOR "$1" "33")
}

BLUE(){
    echo $(COLOR "$1" "34")
}
