build lab-number:
    mkdir -p build/
    typst compile --input lab-number={{lab-number}} ./main.typ \
    "./build/[CE 4204] Lab {{lab-number}} Report.pdf"

watch lab-number:
    mkdir -p build/
    typst watch --input lab-number={{lab-number}} ./main.typ \
    "./build/[CE 4204] Lab {{lab-number}} Report.pdf"
