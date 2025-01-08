/**
* @description Combo input element mixing selects with inputs 
* authored by the person registered as the profile "CSingendonk" on github.com
* please give credit to the author if this is used in your code outside of CSingendonk's repos, forked, pulled, copied, etc, for any work that includes or is derived from this
*/
class CustomSelectInput extends HTMLElement {
        constructor() {
            super();
            this.#shadow = this.attachShadow({ mode: 'closed' });
            this.state = {
                value: '',
                options: [],
                placeholder: '',
                selectionMode: 'single',
                selections: [],
                innerstyles: '',
            };
            this.textbox = this.#textbox;
            this.dropdown = this.#dropdown;
            this.announcementRegion = null;
            this.contextMenu = this.#contextMenu;
            this.contextMenu.create();
        }
        #shadow;
        #textbox = (() => { return this.textbox; })();
        #dropdown = (() => { return this.dropdown; })();
        static get observedAttributes() {
            return ['data-placeholder', 'data-options', 'data-value', 'data-selection-mode', 'data-style'];
        }
    
    
        connectedCallback() {
            this.#render();
            this.#initializeState();
            this.#initializeAttributes();
            this.#setupEventListeners();
        }
    
        disconnectedCallback() {
            this.#cleanupEventListeners();
        }
    
        attributeChangedCallback(name, oldValue, newValue) {
            if (oldValue === newValue || (!oldValue && !newValue) || !name) return;
            const handlers = {
                'data-value': () => this.#updateValue(newValue),
                'data-options': () => {
                    this.state.options = this.#parseOptions(newValue);
                    this.#syncOptionsWithSelect();
                },
                'data-placeholder': () => this.#updatePlaceholder(newValue),
                'data-selection-mode': () => this.#updateSelectionMode(newValue),
                'data-style': () => this.#updateStyles(newValue)
            };
            handlers[name]?.();
        }
    
        #updateStyles(dataStyles) {
            try {
                const styleRules = JSON.parse(dataStyles);
                if (!Array.isArray(styleRules)) return false;
    
                styleRules.forEach(([selector, styles]) => {
                    if (!selector || !styles) return;
                    
                    const elements = selector === 'this' 
                        ? [this] 
                        : Array.from(this.#shadow.querySelectorAll(selector));
    
                    elements.forEach(element => {
                        if (typeof styles === 'string') {
                            const styleObj = {};
                            styles.split(';')
                                .filter(style => style.trim())
                                .forEach(style => {
                                    const [prop, value] = style.split(':').map(s => s.trim());
                                    if (prop && value) {
                                        styleObj[prop] = value;
                                    }
                                });
                            this.#applyStyles(element, styleObj);
                        } else if (typeof styles === 'object') {
                            this.#applyStyles(element, styles);
                        }
                    });
                });
                return true;
            } catch (error) {
                console.error('Error parsing styles:', error);
                return false;
            }
        }
    
        #applyStyles(element, styles) {
            if (!element || !styles) return;
            Object.entries(styles).forEach(([property, value]) => {
                element.style[property] = value;
            });
        }
        #initializeState() {
            this.#textbox = this.#shadow.querySelector('input');
            this.#dropdown = this.#shadow.querySelector('select');
            this.announcementRegion = document.querySelector('#announcement');
        }
    
        #initializeAttributes() {
            this.state.placeholder = this.getAttribute('data-placeholder') || 'Type/Select an option';
            this.state.options = this.#parseOptions(this.getAttribute('data-options'));
            this.state.value = this.getAttribute('data-value') || '';
            this.state.selectionMode = this.getAttribute('data-selection-mode') || 'single';
            this.state.innerstyles = this.getAttribute('data-style') || '[["this":"{color":"black";}]]';
            this.#updateUI();
        }
    
        #setupEventListeners() {
            this.#textbox?.addEventListener('input', this.#handleTextInput.bind(this));
            this.#textbox?.addEventListener('keydown', this.#handleKeyPress.bind(this));
            this.#dropdown?.addEventListener('keydown', this.#handleTextInput.bind(this));
            this.#dropdown?.addEventListener('change', this.#handleSelectChange.bind(this));
            this.#dropdown?.addEventListener('focus', this.#handleFocus.apply(this));
            this.addEventListener('dblclick', this.#handleDblClick.bind(this));
            this.addEventListener('contextmeu', this.#handleRightClick.bind(this));
            this.#textbox.addEventListener('contextmenu', this.#handleRightClick.bind(this));
    
        }
    
        #cleanupEventListeners() {
            this.#textbox?.removeEventListener('input', this.#handleTextInput);
            this.#textbox?.removeEventListener('keydown', this.#handleKeyPress);
            this.#textbox.removeEventListener('contextmenu', this.#handleRightClick);
    
            this.#dropdown.removeEventListener('keydown', this.#handleTextInput);
            this.#dropdown?.removeEventListener('change', this.#handleSelectChange);
            this.#dropdown?.removeEventListener('focus', this.#handleFocus);
            
            this.removeEventListener('dblclick', this.#handleDblClick);
            this.removeEventListener('contextmenu', this.#handleRightClick);
        }
    
        #render() {
            const template = `<style>:host {display: inline-block;width: 200px;height: 1.5rem;contain: strict;position: initial;color: black;border: 2px groove #000;background-color: #fff}* {background-color: #282c34;color: #fff;font-family: 'Arial', sans-serif;font-size: 14px;line-height: 1.25rem;margin: 0;padding: 0;width: 100%;box-sizing: border-box;min-height: 1.5rem;}input, select {border: 1px solid #555;border-radius: 4px;padding: 0.25rem;position: absolute;left: 0;top: 0;float: left;position: relative;clear: none;z-index: 1;}select {width: fit-coontent;height: 2rem;max-height: 0px;overflow: hidden;z-index: 0;}input {width: 90%;z-index: 9999999999;position: absolute;float: left;clear: none;bottom: 0;right: 10%;}option {}div, div * {height: 100%;} div {padding: 0px;min-height: 100%;}div:nth-child(2) > select:nth-child(1) {top: 0;bottom:0;border: initial;outline: initial;box-shadow: initial;}:host * {background-color: inherit;color: inherit;font-family: inherit;font-size: inherit;line-height: inherit;margin: 0;border: none;border-radius: 0;}select {color: transparent;background-color: transparent;}option {border: 1px solid black;border-radius: 50%;}</style><div><select style="top: 0px;"><option value=""></option><option value="fuck">fuck</option><option value="fuckit">fuckit</option><option value="it">]</option></select><input type="text" placeholder="Type/Select an option" style="width: 90%;z-index: 9999999999;position: absolute;float: left;clear: none;bottom: 0;right: 10%;"></div>`;
            this.#shadow.innerHTML = template;
            this.style.padding = '0px';
            this.#initializeState();
        }
    
        #updateUI() {
            this.#updatePlaceholder(this.state.placeholder);
            this.#updateValue(this.state.value || this.state.options[0]?.value || '');
            this.#syncOptionsWithSelect();
            this.#positionDropdown();
        }
    
        #updateSelectionMode(mode) {
            this.state.selectionMode = ['single', 'multiple'].includes(mode) ? mode : 'single';
            this.#dropdown.multiple = this.state.selectionMode === 'multiple';
            this.#syncOptionsWithSelect();
        }

        #parseOptions(optionsData) {
            if (!optionsData || !(typeof optionsData == 'string' && optionsData?.length > 0)) return this.#getDefaultOptions();
            try {
                if (optionsData.startsWith('[{')) {
                    const parsedOptions = JSON.parse(optionsData);
                    return parsedOptions.map(opt => {
                        if (!opt.value && !opt.text) {
                            return { value: '', text: '' };
                        }
                        if (!opt.value && opt.text) {
                            return { value: opt.text, text: opt.text };
                        }
                        if (!opt.text && opt.value) {
                            return { value: opt.value, text: opt.value };
                        }
                        return { value: opt.value, text: opt.text };
                    });
                }
                let od = optionsData
                    .trim()
                    .replace(/^[\[\]]/g, '')
                    .split(',')
                    .map(opt => {
                        const parts = opt.trim().split(':').map(part => 
                            part.trim()
                                .replace(/^['"]|['"]$/g, '') // Remove quotes at start/end
                                .replace(/[\[\]]/g, '') // Remove any brackets
                                .replace(/^[\s]*$/, '') // Handle empty or whitespace-only parts
                        );
                        
                        if (parts.length === 1) {
                            const value = parts[0];
                            return { value: value || '', text: value || '' };
                        }
                        
                        const [value, text] = parts;
                        if (!value && text) {
                            return { value: text, text: text };
                        }
                        return { value: value || text || '', text: text || value || '' };
                    });
                    od.forEach(o => {
                        if (o.value) {
                            o.value = o.value
                                .replace(/[\[\]]/g, '')
                                .replace(/['"]/g, '');
                        }
                        if (o.text) {
                            o.text = o.text
                                .replace(/[\[\]]/g, '')
                                .replace(/['"]/g, '');
                        }
                    });
                    return od;
            } catch {
                return this.#getDefaultOptions();
            }
        }    
        #getDefaultOptions() {
            if ((this.getAttribute('data-options') == null || this.getAttribute('data-options') == '' || this.getAttribute('data-options') == '[]' || this.getAttribute('data-options') == '""') || !this.getAttribute('data-options')) {
                this.setAttribute('data-options', '[{"value":"","text":""}]');
                return [{ value: '', text: '' }];
            }
            else {
                return this.#parseOptions(this.getAttribute('data-options'));
            };
        }
    
        #syncOptionsWithSelect() {
            if (!this.#dropdown) return;
            
            while (this.#dropdown.firstChild) {
                this.#dropdown.removeChild(this.#dropdown.firstChild);
            }
            
            this.state.options.forEach(opt => {
                const option = document.createElement('option');
                option.value = opt.value;
                option.textContent = opt.text;
                this.#dropdown.appendChild(option);
            });
    
            this.#dropdown.value = this.state.value;
        }
        #handleTextInput(event = { target: this.#textbox }) {
            this.state.value = event.target.value;
            this.#announce(`Input updated to: ${this.state.value}`);
            this.dispatchEvent(new CustomEvent('input-changed', {
                detail: { value: this.state.value },
                bubbles: true,
                composed: true,
                view: null
            }));
        }
    
        #handleKeyPress(event = { key: 'Enter', target: this.#textbox }) {
            if (event.key === 'Enter' && this.#textbox.value.trim()) {
                const value = this.#textbox.value;
                if (!this.state.options.some(opt => opt.value === value)) {
                    this.state.options.push({ value, text: value });
                    this.#syncOptionsWithSelect();
                }
                this.#updateValue(value);
                this.#announce(`Option added: ${value}`);
                this.dispatchEvent(new CustomEvent('input-added', {
                    detail: { value: value },
                    bubbles: true,
                    composed: true,
                    view: null
                }));
            }
        }
    
        #handleSelectChange(event = { target: this.#dropdown }) {
            if (event.target === this.#dropdown) {
                this.state.value = event.target.value;
                this.#updateValue(this.state.value);
                this.#announce(`Selected option: ${this.state.value}`);
                this.dispatchEvent(new CustomEvent('selection-changed', {
                    detail: { value: this.state.value },
                    bubbles: true,
                    composed: true,
                    view: null
                }));
            }
        }

        #handleFocus(e = { target: this.#textbox }) {
            const t = e.target;
            const t2 = e.target == this.#textbox ? this.#dropdown : this.#textbox;
            if (t == this.#dropdown) {
                t2.focus();
            }
            t.style.border = 'initial';
            t.style.outline = 'initial';
            t.style.boxShadow = 'initial';
            t2.style.border = 'initial';
            t2.style.outline = 'initial';
            t2.style.boxShadow = 'initial';
        }
          #lastClick = 0;
    
        #showList = () => {
            this.appliedpicker = HTMLSelectElement.prototype.showPicker.bind(this.#dropdown);
            this.appliedpicker.call(this.#dropdown);
          }
    
        #handleDblClick(e) {
              this.#showList();
          }

        #contextMenu = {
            isVisible: false,
            element: null,
            x: 0,
            y: 0,
            items: [],
            
            create() {
                if (this.element) return;
                
                this.element = document.createElement('div');
                Object.assign(this.element.style, {
                    position: 'fixed',
                    backgroundColor: '#fff',
                    border: '1px solid #ccc',
                    padding: '5px',
                    boxShadow: '2px 2px 5px rgba(0,0,0,0.2)',
                    zIndex: '1000',
                    display: 'none'
                });
            },
    
            addItem(text, action, icon = '') {
                const item = document.createElement('div');
                Object.assign(item.style, {
                    padding: '5px 10px',
                    cursor: 'pointer',
                    userSelect: 'none'
                });
                item.className = 'context-menu-item';
                
                if (icon) {
                    const iconElement = document.createElement('span');
                    iconElement.className = icon;
                    item.appendChild(iconElement);
                }
                
                item.appendChild(document.createTextNode(text));
                
                const handleClick = (e) => {
                    e.stopPropagation();
                    action();
                    this.hide();
                };
                
                const handleHover = (isOver) => {
                    item.style.backgroundColor = isOver ? '#f0f0f0' : 'transparent';
                };
                
                item.addEventListener('click', handleClick);
                item.addEventListener('mouseover', () => handleHover(true));
                item.addEventListener('mouseout', () => handleHover(false));
                
                this.items.push(item);
                this.element?.appendChild(item);
            },
    
            show(x, y) {
                if (!this.element) this.create();
                
                Object.assign(this.element.style, {
                    display: 'block',
                    left: `${x}px`,
                    top: `${y}px`
                });
                
                this.isVisible = true;
                document.body.appendChild(this.element);
                
                const rect = this.element.getBoundingClientRect();
                if (rect.right > window.innerWidth) {
                    this.element.style.left = `${window.innerWidth - rect.width}px`;
                }
                if (rect.bottom > window.innerHeight) {
                    this.element.style.top = `${window.innerHeight - rect.height}px`;
                }
            },
    
            hide() {
                if (this.element) {
                    this.element.style.display = 'none';
                }
                this.clear();
                this.isVisible = false;
            },
    
            clear() {
                this.items.forEach(item => item.remove());
                this.items = [];
            },
        
            destroy() {
                this.clear();
                this.element?.remove();

                this.element = null;
                this.isVisible = false;
            },
    
            bypass: (e) => {
                if (this.isVisible) {
                    this.hide();
                    e.target.dispatchEvent(new MouseEvent("contextmenu", {
                        bubbles: true,
                        cancelable: true,
                        view: window,
                        detail: 0,
                        screenX: 0,
                        screenY: 0,
                        clientX: 0,
                        clientY: 0,
                        ctrlKey: false,
                        altKey: false,
                        shiftKey: false,
                        metaKey: false,
                        button: 2,
                        relatedTarget: null
                    }));
                    return;
                }
                this.hide();
            },

            bypassEvent(e) {
                setTimeout(() => {
                    const nativeEvent = new MouseEvent("contextmenu", {
                        ...e
                    });
                    e.target.dispatchEvent(nativeEvent);
                }, 10);
            }
        };    
        #handleRightClick(e) {
            e.preventDefault();
            
            if (this.#contextMenu?.isVisible) {
                this.#contextMenu.bypass(e);
                return;
            }

            if (!this.#contextMenu?.exists) {
                this.contextMenu.create();
                this.#initializeContextMenuItems();
            }    

            this.#showContextMenu(e);
            this.#addGlobalClickHandler();
            this.#contextMenu.element.title = 'Right click again to show normal menu\nClick anywhere else to hide this menu';
        }

        #initializeContextMenuItems() {
            const showInfo = () => {
                const infoContent = `
                <ul>
                    <li>HTML Attributes:
                        <ul>
                            <li>data-options:
                                <ul>
                                    <li>value==text:
                                        <ul>
                                            <li>"[a,b,c]" becomes "[{"value":"a","text":"a"},{"value":"b","text":"b"},{"value":"c","text":"c"}]"</li>
                                        </ul>
                                    </li>
                                    <li>value && text:
                                        <ul>
                                            <li>"[a:1,b:2,c:3]" becomes '[{"value":"a","text":"1"},{"value":"b","text":"2"},{"value":"c","text":"3"}]'</li>
                                        </ul>
                                    </li>
                                </ul>
                            </li>
                            <li>data-value: the value property value of the selected option</li>
                            <li>data-placeholder: the placeholder to display when value is '' or null</li>
                        </ul>
                    </li>
                </ul>`;

                const infoDialog = document.createElement('dialog');
                infoDialog.innerHTML = infoContent;
                document.body.appendChild(infoDialog);
                infoDialog.showModal();

                infoDialog.addEventListener('click', (e) => {
                    if (e.target === infoDialog) {
                        infoDialog.close();
                        infoDialog.remove();
                    }
                });
            };

            this.#contextMenu.addItem('Show Info', showInfo);                
            this.#contextMenu.addItem('Close', () => this.#contextMenu.hide());
        }

        #showContextMenu(e) {
            this.#contextMenu.show(e.clientX, e.clientY);
            this.#contextMenu.isVisible = true;
        }

        #addGlobalClickHandler() {
            const hideHandler = (event) => {
                if (!this.#contextMenu.element.contains(event.target)) {
                    this.#contextMenu.hide();
                    document.removeEventListener('click', hideHandler);
                    document.removeEventListener('contextmenu', hideHandler);
                } else {
                    event.target.dispatchEvent(new PointerEvent('contextmenu', this.#contextMenu.bypass(), { bubbles: true }));
                }
                this.#contextMenu.title = null;
            };
            
            document.addEventListener('click', hideHandler);
        }    
        removeContextMenu() {
            if (this.#contextMenu) {
                this.#contextMenu.destroy();
            }
        }
        #updateValue(value) {
            if (this.state.selectionMode === 'multiple') {
                if (Array.isArray(value)) {
                    this.state.value = value.join(',');
                } else if (typeof value === 'string') {
                    this.state.value = value.split(',')
                        .map(v => v.trim())
                        .filter(v => v !== '')
                        .join(',');
                }
            } else {
                this.state.value = Array.isArray(value) ? value[0] : value;
            }
    
            this.setAttribute('data-value', this.state.value);
            this.setAttribute('data-options', JSON.stringify(this.state.options));
    
            if (this.#textbox) {
                this.#textbox.value = this.state.value;
            }
    
            if (this.#dropdown) {
                if (this.state.selectionMode === 'multiple') {
                    const values = this.state.value.split(',');
                    Array.from(this.#dropdown.options).forEach(option => {
                        option.selected = values.includes(option.value);
                    });
                } else {
                    this.#dropdown.value = this.state.value;
                }
            }
    
            if (!this.state.options.some(opt => opt.value === this.state.value)) {
                this.state.options.push({ value: this.state.value, text: this.state.value });
                this.#syncOptionsWithSelect();
            }
        }
        #updatePlaceholder(placeholder) {
            if (this.#textbox) this.#textbox.placeholder = placeholder;
        }
    
        announcementRegion = () => {
            const ar = document.createElement('p');
    
            ar.style = {
                position: 'absolute',
                overflow: 'hidden',
                zIndex: '9999',
                backgroundColor: '#f0f0f0dd'
            }
            document.body.appendChild(ar);
            return ar;
        }
    
        #announce(message) {
            if (this.announcementRegion) {
                this.announcementRegion.textContent = message;
            }
        }
    
        #positionDropdown() {
            if (!this.#textbox || !this.#dropdown) return;
            const textboxRect = this.#textbox.getBoundingClientRect();
            const dropdownRect = this.#dropdown.getBoundingClientRect();
            const dropdownHeight = dropdownRect.height;
            const textboxHeight = textboxRect.height;
            const dropdownTop = textboxRect.bottom;
            const dropdownLeft = textboxRect.left;
            this.style.top = `${textboxRect.top}px`;
            this.style.left = `${dropdownLeft * textboxRect.left / 2}px`;
            if (this.style.height != this.#dropdown.style.height) {
                this.#textbox.style.height = this.style.height;
            }
            if (this.style.height != this.#dropdown.style.height) {
                this.#dropdown.style.height = this.#textbox.style.height;
            }
            if (this.#textbox.style.fontSize > this.style.height - this.#textbox.style.padding) {
                this.#textbox.style.fontSize = this.style.height - this.#textbox.style.padding;
            }
        }
    
        #determineBrowser() {
            const userAgent = navigator?.userAgent;
            let codeName = 'Unknown';
    
            const browserPatterns = [
                { pattern: "Chrome", name: "Google Chrome", excludes: ["Edge", "OPR"] },
                { pattern: "Firefox", name: "Mozilla Firefox" },
                { pattern: "Safari", name: "Safari", excludes: ["Chrome"] },
                { pattern: "Edge", name: "Microsoft Edge" },
                { pattern: ["OPR", "Opera"], name: "Opera" },
                { pattern: ["MSIE", "Trident"], name: "Internet Explorer" }
            ];
    
            for (const browser of browserPatterns) {
                const patterns = Array.isArray(browser.pattern) ? browser.pattern : [browser.pattern];
                const hasPattern = patterns.some(pattern => userAgent.indexOf(pattern) > -1);
                const noExcludes = !browser.excludes?.some(exclude => userAgent.indexOf(exclude) > -1);
    
                if (hasPattern && noExcludes) {
                    codeName = browser.name;
                    break;
                }
            }
            consolee.log(`Browser: ${codeName}    \n fuckinshitt355`);
            return codeName;
        }
    
        #browserSpecificStyleDefaults(ofName = 'Unknown') {
            const sets = {
                'Google Chrome': (() => {
                    return {
                        border: '1px solid #ccc',
                        outline: 'none',
                        borderRadius: '4px',
                        // and so on, such as that the select, input, and containing elements in the custom elements' shadow DOM are rendered the same across browsers.
                    };
                })(),
                'Mozilla Firefox': (() => {
                    return {
                        border: '1px solid #ccc',
                        outline: 'none',
                        borderRadius: '4px',
                        // and so on, such as that the select, input, and containing elements in the custom elements' shadow DOM are rendered the same across browsers.
                    };
                })(),
                'Safari': (() => {
                    return {
                        border: '1px solid #ccc',
                        outline: 'none',
                        borderRadius: '4px',
                        // and so on, such as that the select, input, and containing elements in the custom elements' shadow DOM are rendered the same across browsers.
                    };
                })(),
                'Microsoft Edge': (() => {
                    return {
                        border: '1px solid #ccc',
                        outline: 'none',
                        borderRadius: '4px',
                        // and so on, such as that the select, input, and containing elements in the custom elements' shadow DOM are rendered the same across browsers.
                    };
                })(),
                'Opera': (() => {
                    return {
                        border: '1px solid #ccc',
                        outline: ''
                    }
                })
            };
            const matchingBrowser = Object.keys(sets).find(setName =>
                ofName.includes(setName) || setName.includes(ofName)
            );
    
            return matchingBrowser ? sets[matchingBrowser] : sets['Google Chrome'];
        }
    
    
        #applyBrowserSpecificStyles(styles, browsername, what, these) {
            let that = this;
            const thisBrowser = browsername == null ? this.#determineBrowser() : browsername;
            const browserSpecificStyles = this.#browserSpecificStyleDefaults(thisBrowser);
            if (this[what] != null) {
                if (Array.from(this.#shadow.querySelector('*')).includes(this[what])) {
                    that = this[what];
                    this.#applyStyles(browserSpecificStyles, that, these);
            }};
        }
        applyBrowserStyles = (styles = {...Object.entries(this.styles)}, that = this, these = []) => {
                if (that != null && these != null && Array.isArray(these)) {
                    these.push(that);
                } else if (that != null){
                    these = [that];
                } else {
                    these = [];
                }
                for (const [property, value] of Object.entries(styles)) {
                    element.style[property] = value;
                }
                if (these.length > 0) {
                    these.pop();
                    applyStyles(styles, these[0], these);
                }
                return these;
        };
    
    
    
        static createComboInput = (() => { return document.createElement('combo-input'); })();
    
    }
    
    customElements.define('combo-input', CustomSelectInput);

    
