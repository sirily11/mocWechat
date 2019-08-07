// adapted from https://github.com/schickling/calculate-size to support any style attribute
// get from https://codesandbox.io/s/5z282z7q1l via comment https://github.com/bvaughn/react-window/issues/6#issuecomment-424813350

/**
 * An object with the keys width and height.
 * @typedef SizeObject
 * @property {Number} width - offsetWidth
 * @property {Number} height - offsetHeight
 */

/**
 * An object with the keys text, attributes and className.
 * @typedef getSizeConfig
 * @property {String} text - The text string to insert into the element.
 * @property {Object} attributes - The attributes to be added to the `style` of the created element.
 * @property {String} className - A list of classes to be added to the element.
 */

/**
 * Create a dummy HTML element with the provided configuration.
 * @param {getSizeConfig} config - The configuration object for creating the element.
 * @returns {HTMLElement} The created HTML element.
 */
function createDummyElement({ text, attributes, className }) {
    const element = document.createElement("div");
    const textNode = document.createTextNode(text);
  
    element.appendChild(textNode);
    element.style.position = "absolute";
    element.style.visibility = "hidden";
    element.style.left = "-999px";
    element.style.top = "-999px";
    element.className = className;
    Object.keys(attributes).forEach(attribute => {
      element.style[attribute] = attributes[attribute];
    });
    document.body.appendChild(element);
  
    return element;
  }
  
  /**
   * Delete a HTML element from the dom.
   * @param {HTMLElement} element - The HTMLElement to delete.
   */
  function destroyElement(element) {
    element.parentNode.removeChild(element);
  }
  
  /**
   * Get the size of an element based on provided text and style attributes.
   * @param {getSizeConfig} config - The configuration object for getSize.
   * @returns {SizeObject}
   */
  export default function getHeight({
    text = "",
    attributes = {},
    className = ""
  }) {
    const element = createDummyElement({ text, attributes, className });
    const height = element.offsetHeight;
    destroyElement(element);
    console.log( height );
    return height;
  }
  