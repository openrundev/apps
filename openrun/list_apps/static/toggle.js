// Theme toggle + nav drawer behaviors, following the console app
// (ui/console/static/console.js).

// The mobile hamburger is a real button (keyboard operable, unlike a bare
// label): toggles the drawer checkbox and keeps aria-expanded in sync,
// moving focus to the folder nav when opening
function toggleNavDrawer(btn) {
	const drawer = document.getElementById('nav-drawer');
	if (!drawer) {
		return;
	}
	drawer.checked = !drawer.checked;
	btn.setAttribute('aria-expanded', drawer.checked ? 'true' : 'false');
	if (drawer.checked) {
		const nav = document.getElementById('folder-nav');
		if (nav) {
			nav.focus();
		}
	}
}

document.addEventListener('DOMContentLoaded', () => {
	// Persist the user's theme choice. The toggle's initial state is set by
	// an inline script next to it in the sidebar, before first paint, so
	// the swap animation does not play on page load
	const toggle = document.getElementById('theme-toggle');
	if (toggle) {
		toggle.addEventListener('change', (event) => {
			const theme = event.target.checked ? 'light' : 'dark';
			document.documentElement.setAttribute('data-theme', 'openrun-' + theme);
			localStorage.setItem('theme', theme);
		});
	}

	// Keep the hamburger's aria-expanded in sync when the drawer is closed
	// by the overlay click instead of the button
	const drawer = document.getElementById('nav-drawer');
	if (drawer) {
		drawer.addEventListener('change', () => {
			for (const btn of document.querySelectorAll('[aria-controls="folder-nav"]')) {
				btn.setAttribute('aria-expanded', drawer.checked ? 'true' : 'false');
			}
		});
	}

	// Tree clicks fetch over htmx instead of a full page load, so close
	// the mobile drawer explicitly. Clicks on childless rows also skip
	// the server-side tree rebuild (the X-Tree-Skip header, see app.star
	// regen_tree), so for those the active row highlight moves here; all
	// other requests re-render the tree out-of-band with the right state.
	// Delegated from the document because those rebuilds replace the tree
	document.addEventListener('click', (event) => {
		const link = event.target.closest('#folder-nav a');
		if (!link) {
			return;
		}
		const drawer = document.getElementById('nav-drawer');
		if (drawer && drawer.checked) {
			drawer.checked = false;
			drawer.dispatchEvent(new Event('change'));
		}
		const headers = link.getAttribute('hx-headers');
		if (!headers || !headers.includes('X-Tree-Skip')) {
			return;
		}
		const glob = new URL(link.href).searchParams.get('path') || '';
		for (const row of document.querySelectorAll('#folder-nav .tree-row')) {
			const active = (new URL(row.href).searchParams.get('path') || '') == glob;
			row.classList.toggle('tree-active', active);
			if (active) {
				row.setAttribute('aria-current', 'page');
			} else {
				row.removeAttribute('aria-current');
			}
		}
	});

	// Escape closes the nav drawer when it is open
	document.addEventListener('keydown', (event) => {
		if (event.key == 'Escape') {
			const drawer = document.getElementById('nav-drawer');
			if (drawer && drawer.checked) {
				drawer.checked = false;
				drawer.dispatchEvent(new Event('change'));
				const btn = document.querySelector('[aria-controls="folder-nav"]');
				if (btn) {
					btn.focus();
				}
			}
		}
	});
});
