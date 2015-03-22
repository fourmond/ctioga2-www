// Search in images.

function toggleExamples(el) {
    var tgt = el.id;
    tgt = tgt.replace("-h5-", "-");
    var el = document.getElementById(tgt);
    // Can't get fade in and out to work, don't know why
    if(!el.style.display || el.style.display == "none") {
        el.style.display = "inherit";
    }
    else {
        el.style.display = "none";
    }
}


