function write_random(rel)
{
    var i = Math.floor((Math.random()*random_items.length)); 
    var val = random_items[i];
    rel = rel.replace("index.html", "");
    var ret = val.replace(/\$\$/g, rel);
    document.write(ret);
} 