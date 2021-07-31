var ajax = {};
ajax.x = function () {
  if (typeof XMLHttpRequest !== "undefined") {
    return new XMLHttpRequest();
  }
  var versions = [
    "MSXML2.XmlHttp.6.0",
    "MSXML2.XmlHttp.5.0",
    "MSXML2.XmlHttp.4.0",
    "MSXML2.XmlHttp.3.0",
    "MSXML2.XmlHttp.2.0",
    "Microsoft.XmlHttp",
  ];

  var xhr;
  for (var i = 0; i < versions.length; i++) {
    try {
      xhr = new ActiveXObject(versions[i]);
      break;
    } catch (e) {}
  }
  return xhr;
};

ajax.send = function (url, callback, method, data, async) {
  if (async === undefined) {
    async = true;
  }
  var x = ajax.x();
  x.open(method, url, async);
  x.onreadystatechange = function () {
    if (x.readyState == 4) {
      callback(x.responseText);
    }
  };
  if (method == "POST") {
    x.setRequestHeader(
      "Content-type",
      "application/x-www-form-urlencoded"
    );
  }
  x.send(data);
};

ajax.get = function (url, data, callback, async) {
  var query = [];
  for (var key in data) {
    query.push(
      encodeURIComponent(key) + "=" + encodeURIComponent(data[key])
    );
  }
  ajax.send(
    url + (query.length ? "?" + query.join("&") : ""),
    callback,
    "GET",
    null,
    async
  );
};

var RemotelyPackages = [],
  ChocoURLJS = "https://community.chocolatey.org";

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
    return (
      proxyURL +
      encodeURIComponent(
        ChocoURLJS + "/packages?q=" + packageName.replace(/\s{1,}/gm, "+")
      )
    );
  };
  var proxyURLChosed = proxies[loadBalance(0, 1)];
  return ajax.get(
    parsePackageName(proxyURLChosed, packageName),
    null,
    fetchList
  );
}

function fetchList(data) {
  //var response = JSON.parse(data).contents ?? JSON.parse(data),
  var response = JSON.parse(data).contents,
    parse_html = parseHTML(response),
    list = parse_html.querySelectorAll(".package-list-view li"),
    packageNameRegex = /(.*)<.*>.*<\/.*>/gm,
    packageVersionRegex = /.*<.*>(.*)<\/.*>/gm,
    packageImageRegex = /file:\/{1,}[A-Z]\:/gm;

    for (var i = 0; i < list.length; i++) {
    if (
      list[i].querySelector("a.h5") &&
      list[i].querySelector("div.input-group input")
    ) {
      var packageObject = {
        packageName: list[i]
          .querySelector("a.h5")
          .innerHTML.replace(packageNameRegex, "$1")
          .trim(),
        packageVersion: list[i]
          .querySelector("a.h5")
          .innerHTML.replace(packageVersionRegex, "$1"),
        packageIcon:
          ChocoURLJS +
          list[i].querySelector("img").src.replace(packageImageRegex, ""),
        packageCommand: list[i].querySelector("input").value,
      };
      RemotelyPackages.push(packageObject);
    }
  }
  return RemotelyPackages;
}