"use strict";

function _defineProperty(obj, key, value) {
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value: value,
      enumerable: true,
      configurable: true,
      writable: true,
    });
  } else {
    obj[key] = value;
  }
  return obj;
}

function _classPrivateFieldGet(receiver, privateMap) {
  var descriptor = _classExtractFieldDescriptor(receiver, privateMap, "get");
  return _classApplyDescriptorGet(receiver, descriptor);
}

function _classApplyDescriptorGet(receiver, descriptor) {
  if (descriptor.get) {
    return descriptor.get.call(receiver);
  }
  return descriptor.value;
}

function _classPrivateFieldSet(receiver, privateMap, value) {
  var descriptor = _classExtractFieldDescriptor(receiver, privateMap, "set");
  _classApplyDescriptorSet(receiver, descriptor, value);
  return value;
}

function _classExtractFieldDescriptor(receiver, privateMap, action) {
  if (!privateMap.has(receiver)) {
    throw new TypeError(
      "attempted to " + action + " private field on non-instance"
    );
  }
  return privateMap.get(receiver);
}

function _classApplyDescriptorSet(receiver, descriptor, value) {
  if (descriptor.set) {
    descriptor.set.call(receiver, value);
  } else {
    if (!descriptor.writable) {
      throw new TypeError("attempted to set read only private field");
    }
    descriptor.value = value;
  }
}

var _proxyURLAllOrigins = /*#__PURE__*/ new WeakMap();

var _proxyURLThingProxy = /*#__PURE__*/ new WeakMap();

var _proxyURLChosed = /*#__PURE__*/ new WeakMap();

var _packageName = /*#__PURE__*/ new WeakMap();

var _parseHTML = /*#__PURE__*/ new WeakMap();

class FetchPackage {
  constructor() {
    _proxyURLAllOrigins.set(this, {
      writable: true,
      value: "https://api.allorigins.win/get?url=",
    });

    _proxyURLThingProxy.set(this, {
      writable: true,
      value: "https://api.allorigins.win/get?url=",
    });

    _proxyURLChosed.set(this, {
      writable: true,
      value: "",
    });

    _packageName.set(this, {
      writable: true,
      value: "",
    });

    _defineProperty(this, "packageList", []);

    _parseHTML.set(this, {
      writable: true,
      value: (markup) => {
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
      },
    });

    _defineProperty(this, "fetchPackageList", (packageName) => {
      const repoURL = "https://community.chocolatey.org";
      const regex = /file:\/{1,}[A-Z]\:/gm;

      _classPrivateFieldSet(this, _packageName, packageName);

      const loadBalance = (min, max) => {
        return Math.floor(Math.random() * (max - min + 1) + min);
      };

      const parsePackageName = (proxyURL, packageName) => {
        return (
          proxyURL +
          encodeURIComponent(
            repoURL + "/packages?q=" + packageName.replace(/\s{1,}/gm, "+")
          )
        );
      };

      _classPrivateFieldSet(
        this,
        _proxyURLChosed,
        loadBalance(1, 2) === 1
          ? _classPrivateFieldGet(this, _proxyURLAllOrigins)
          : _classPrivateFieldGet(this, _proxyURLThingProxy)
      );

      return fetch(
        parsePackageName(
          _classPrivateFieldGet(this, _proxyURLChosed),
          packageName
        )
      )
        .then((response) => {
          const contentType = response.headers.get("content-type");

          if (contentType && contentType.indexOf("application/json") !== -1) {
            return response.json();
          } else {
            return response.text();
          }
        })
        .then((data) => {
          var _data$contents;

          const parse_html = _classPrivateFieldGet(this, _parseHTML).call(
            this,
            (_data$contents = data.contents) !== null &&
              _data$contents !== void 0
              ? _data$contents
              : data
          );

          const list = parse_html.querySelectorAll(".package-list-view li");

          for (let item of list) {
            if (
              item.querySelector("a.h5") &&
              item.querySelector("div.input-group input")
            ) {
              let packageObject = {
                packageName: item.querySelector("a.h5").innerText,
                packageIcon:
                  repoURL + item.querySelector("img").src.replace(regex, ""),
                packageCommand: item.querySelector("input").value,
              };
              this.packageList.push(packageObject);
            }
          }

          return this.packageList;
        });
    });
  }
}
