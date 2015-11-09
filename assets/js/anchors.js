/*
 * Credit for this file goes to Parker Moore.
 * See: http://blog.parkermoore.de/2014/08/01/header-anchor-links-in-vanilla-javascript-for-github-pages-and-jekyll/
 */

function anchorForId(id) {
  var anchor = document.createElement("a");
  anchor.className = "header-link";
  anchor.href      = "#" + id;
  anchor.innerHTML = "<i class=\"fa fa-link\"></i>";
  return anchor;
}

function linkifyAnchors(level, containingElement) {
  var headers = containingElement.getElementsByTagName("h" + level);
  for (var h = 0; h < headers.length; h++) {
    var header = headers[h];

    if (typeof header.id !== "undefined" && header.id !== "") {
      header.appendChild(anchorForId(header.id));
    }
  }
}

document.onreadystatechange = function () {
  if (this.readyState === "complete") {
    var contentBlock = document.getElementsByClassName("post-content")[0];
    if (!contentBlock) {
      return;
    }
    for (var level = 1; level <= 4; level++) {
      linkifyAnchors(level, contentBlock);
    }
  }
};
