if (window.NodeList && !NodeList.prototype.forEach)
  NodeList.prototype.forEach = Array.prototype.forEach;

var RemotelyPackages = [];
var ChocoURLJS = "https://community.chocolatey.org";

function parseHTML(markup) {
  if (markup.toLowerCase().trim().indexOf("<!doctype") === 0) {
    var doc = document.implementation.createHTMLDocument("");
    doc.documentElement.innerHTML = markup;
    return doc;
  } else if ("content" in document.createElement("template")) {
    var el = document.createElement("template");
    el.innerHTML = markup;
    return el.content;
  } else {
    var docfrag = document.createDocumentFragment();
    var el = document.createElement("body");
    el.innerHTML = markup;
    for (i = 0; 0 < el.childNodes.length; ) {
      docfrag.appendChild(el.childNodes[i]);
    }
    return docfrag;
  }
}

function fetchPackageList(packageName) {
  var proxies = [
    "https://api.allorigins.win/get?url=",
    "https://api.allorigins.win/get?url=",
  ];
  var loadBalance = function (min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
  };
  var parsePackageName = function (proxyURL, packageName) {
    return (proxyURL + encodeURIComponent(ChocoURLJS + "/packages?q=" + packageName.replace(/\s{1,}/gm, "+")));
  };
  var proxyURLChosed = proxies[loadBalance(0, 1)];
  return ajax.get( parsePackageName(proxyURLChosed, packageName), null, fetchList, false);
}

function fetchList(data) {
  //var response = JSON.parse(data).contents ?? JSON.parse(data),
  var response = JSON.parse(data).contents,
    parse_html = parseHTML(response),
    list = parse_html.querySelectorAll(".package-list-view li"),
    packageNameRegex = /(.*)<.*>.*<\/.*>/gm,
    packageVersionRegex = /.*<.*>(.*)<\/.*>/gm,
    packageImageRegex = /file:\/{1,}[A-Z]\:/gm,
    PackageNumber = 0,
    JSONObj = "",
    ArrayObj,
    Chr34 = String.fromCharCode(34);

  JSONObj = "{";
  JSONObj = JSONObj + Chr34 + "packages" + Chr34 + ":" + "[";

  list.forEach(function (item, i) {
    if (item.querySelector("a.h5") && item.querySelector("div.input-group input")) {
      ArrayObj = "";
      ArrayObj = ArrayObj + "{";
      ArrayObj = ArrayObj + Chr34 + "packageName" + Chr34 + ":" + Chr34 + item.querySelector("a.h5").innerHTML.replace(packageNameRegex, "$1").trim() + Chr34 + ",";
      ArrayObj = ArrayObj + Chr34 + "packageVersion" + Chr34 + ":" + Chr34 + item.querySelector("a.h5").innerHTML.replace(packageVersionRegex, "$1") + Chr34 + ",";
      ArrayObj = ArrayObj + Chr34 + "packageIcon" + Chr34 + ":" + Chr34 + ChocoURLJS + item.querySelector("img").src.replace(packageImageRegex, "") + Chr34 + ",";
      ArrayObj = ArrayObj + Chr34 + "packageCommand" + Chr34 + ":" + Chr34 + item.querySelector("input").value + Chr34;
      ArrayObj = ArrayObj + "},";
      JSONObj = JSONObj + ArrayObj;
      PackageNumber++;
    }
  });

  JSONObj = JSONObj + "]";
  if (PackageNumber > 0) {
    JSONObj = JSONObj.substring(0, JSONObj.length - 2) + "],";
  }
  else {
    JSONObj = JSONObj + ",";
  }
  JSONObj = JSONObj + Chr34 + "package_lenght" + Chr34 + ":" + PackageNumber + "";
  JSONObj = JSONObj + "}";
  return (RemotelyPackages = JSONObj);
}