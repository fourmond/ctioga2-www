// Search in images.

function doSearch(srch) {
    var nf = ""
    for (var key in idx) {
        var txt = idx[key];
        var elem = document.getElementById(key)
        if(elem) {
            if(txt.indexOf(srch) >= 0) {
                // Show
                $("#" + key).fadeIn(250);
            }
            else {
                // Hide
                $("#" + key).fadeOut(250);
            }
        }
        else {
            nf += ", " + key;
        }
    }
}

function clearSearch() {
    doSearch('');
}

function search() {
    var srch = document.getElementById('search').value;
    doSearch(srch);
}

