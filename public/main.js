let menubutton = document.querySelector(".menu-button")
// let menu = document.querySelector(".menu")
let fade_layer = document.querySelector(".fade-layer")
let header = document.querySelector("header")

let burgerone = document.querySelector("#burger-one")
let burgertwo = document.querySelector("#burger-two")
let burgerthree = document.querySelector("#burger-three")

function show(){
    // menu.classList.toggle("show")
    fade_layer.classList.toggle("visible")

    burgerone.classList.toggle("animation-one")
    burgerone.classList.toggle("reverse-one")

    burgertwo.classList.toggle("animation-two")
    burgertwo.classList.toggle("reverse-two")

    burgerthree.classList.toggle("animation-3")
    burgerthree.classList.toggle("reverse-3")
}

fade_layer.addEventListener("click",show)
menubutton.addEventListener("click",show)