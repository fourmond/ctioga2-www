// Search in images.

function toggleExamples(el) {
    var tgt = el.id;
    tgt = tgt.replace("-h5-", "-");
    var el = document.getElementById(tgt);
    $('#' + tgt).fadeToggle();
}


