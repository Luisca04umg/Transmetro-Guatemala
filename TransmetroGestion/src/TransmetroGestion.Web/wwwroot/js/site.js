document.addEventListener("submit", function (event) {
  const form = event.target;
  if (!(form instanceof HTMLFormElement) || form.matches("[data-directory-query]")) return;
  if (form.dataset.submitting === "true") { event.preventDefault(); return; }
  const button = event.submitter;
  if (button && button.name) {
    const value = document.createElement("input");
    value.type = "hidden"; value.name = button.name; value.value = button.value;
    form.appendChild(value);
  }
  form.dataset.submitting = "true";
  if (button) { button.disabled = true; button.textContent = "Procesando..."; }
});
window.addEventListener("pageshow", function () {
  document.querySelectorAll("form").forEach(form => {
    if (form.dataset.submitting === "true") window.location.reload();
  });
});

// Carga limitada: sólo la sección abierta, una página de 20 resúmenes y una ficha.
(() => {
  const states = new WeakMap();
  function bodyOf(panel) { return panel.querySelector(':scope > .lazy-body'); }
  function cancelChildren(panel) {
    panel.querySelectorAll('details[data-lazy-url]').forEach(child => { states.get(child)?.controller?.abort(); states.delete(child); });
  }
  async function load(panel, url = panel?.dataset.lazyUrl) {
    if (!panel) return;
    const body = bodyOf(panel);
    if (!body || !url || !panel.open) return;
    const old = states.get(panel);
    if (old?.loading && old.url === url) return;
    old?.controller?.abort();
    const state = { controller: new AbortController(), loading: true, loaded: false, url };
    states.set(panel, state);
    body.setAttribute('aria-busy', 'true');
    cancelChildren(panel);
    body.replaceChildren();
    const status = document.createElement('p'); status.textContent = 'Cargando…'; status.setAttribute('role', 'status'); body.appendChild(status);
    try {
      const response = await fetch(url, { signal: state.controller.signal, credentials: 'same-origin', cache: 'no-store', headers: { 'X-Requested-With': 'XMLHttpRequest' } });
      if (response.redirected) { window.location.assign(response.url); return; }
      if (!response.ok || response.headers.get('X-Transmetro-Partial') !== 'true') throw new Error('No se pudo cargar la sección.');
      const markup = await response.text();
      if (states.get(panel) !== state || !panel.open || !panel.isConnected) return;
      body.innerHTML = markup;
      state.loaded = true;
    } catch (error) {
      if (error.name === 'AbortError' || states.get(panel) !== state || !panel.open) return;
      body.replaceChildren();
      const message = document.createElement('p'); message.textContent = 'No se pudo cargar la sección. Intente nuevamente.';
      const retry = document.createElement('button'); retry.type = 'button'; retry.dataset.lazyRetry = ''; retry.textContent = 'Reintentar';
      body.append(message, retry);
    } finally {
      state.loading = false;
      if (states.get(panel) === state) body.removeAttribute('aria-busy');
    }
  }
  document.addEventListener('toggle', event => {
    const panel = event.target;
    if (!(panel instanceof HTMLDetailsElement) || !panel.matches('[data-lazy-url]')) return;
    if (panel.open) {
      const state = states.get(panel);
      if (!state?.loaded) load(panel, state?.url || panel.dataset.lazyUrl);
    } else if (panel.hasAttribute('data-lazy-unload')) {
      // Cancela respuestas tardías y elimina también las fichas/combos de la página anterior.
      const state = states.get(panel); state?.controller?.abort();
      cancelChildren(panel); states.delete(panel); bodyOf(panel)?.replaceChildren();
    }
  }, true);
  document.addEventListener('submit', event => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement) || !form.matches('[data-directory-query]')) return;
    event.preventDefault();
    const panel = form.closest('details[data-lazy-url]');
    const url = new URL(form.action, window.location.href); url.search = new URLSearchParams(new FormData(form)).toString();
    load(panel, url.toString());
  });
  document.addEventListener('click', event => {
    const link = event.target.closest('[data-directory-page]');
    if (link && event.button === 0 && !event.ctrlKey && !event.metaKey && !event.shiftKey && !event.altKey) {
      event.preventDefault(); load(link.closest('details[data-lazy-url]'), link.href); return;
    }
    const retry = event.target.closest('[data-lazy-retry]');
    if (retry) { const panel = retry.closest('details[data-lazy-url]'); load(panel, states.get(panel)?.url); }
  });
})();

// Restricciones de campos personales, también en formularios cargados bajo demanda.
(() => {
    const selector = 'input[name="Nombres"], input[name="Apellidos"], input[name="Telefono"]';
    function preparar(contenedor) {
        const campos = [];
        if (contenedor.matches?.(selector)) campos.push(contenedor);
        campos.push(...contenedor.querySelectorAll(selector));
        for (const campo of campos) {
            if (campo.name === 'Telefono') {
                campo.type = 'tel';
                campo.inputMode = 'numeric';
                campo.minLength = 8;
                campo.maxLength = 8;
                campo.pattern = '[0-9]{8}';
                campo.title = 'Ingrese exactamente 8 dígitos, sin espacios ni guiones.';
            } else {
                campo.maxLength = 100;
                campo.pattern = '\\p{L}[\\p{L}\\p{M}]*(?: +\\p{L}[\\p{L}\\p{M}]*)*';
                campo.title = 'Ingrese sólo letras y espacios. Se permiten tildes y ñ.';
            }
        }
    }
    preparar(document);
    new MutationObserver(cambios => {
        for (const cambio of cambios) {
            for (const nodo of cambio.addedNodes) {
                if (nodo instanceof Element) preparar(nodo);
            }
        }
    }).observe(document.body, { childList: true, subtree: true });
})();
