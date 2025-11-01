let instances = [
    "anarchist.nexus",
    "ani.social",
    "awful.systems",
    "beehaw.org",
    "discuss.online",
    "discuss.tchncs.de",
    "feddit.dk",
    "feddit.it",
    "feddit.nl",
    "feddit.nu",
    "feddit.online",
    "feddit.org",
    "feddit.uk",
    "forum.guncadindex.com",
    "fosscad.io",
    "infosec.pub",
    "leminal.space",
    "lemmings.world",
    "lemmy.blahaj.zone",
    "lemmy.ca",
    "lemmy.cafe",
    "lemmy.dbzer0.com",
    "lemmy.eco.br",
    "lemmy.ml",
    "lemmy.nz",
    "lemmy.sdf.org",
    "lemmy.today",
    "lemmy.world",
    "lemmy.zip",
    "lemmygrad.ml",
    "lemy.lol",
    "literature.cafe",
    "mander.xyz",
    "midwest.social",
    "pawb.social",
    "piefed.blahaj.zone",
    "piefed.ca",
    "piefed.social",
    "piefed.world",
    "piefed.zip",
    "programming.dev",
    "reddthat.com",
    "sh.itjust.works",
    "slrpnk.net",
    "sopuli.xyz",
    "startrek.website",
    "szmer.info",
    "thelemmy.club",
    "ttrpg.network"
];

document.addEventListener('readystatechange', handleNavigation);

let previousReadyState;

function handleNavigation() {
    if (previousReadyState === document.readyState) return;
    previousReadyState = document.readyState;
    
    // Wait until the page is fully loaded
    if (document.readyState !== 'complete') return;
    
    // Double check that host matches one of the instances
    if (matchesHost(document.location.host, instances)) {
        openInThunder();
    }
}

function matchesHost(host, allowedHosts) {
    return allowedHosts.includes(host);
}

function openInThunder() {
    let url = new URL('thunder:' + document.location.href.slice(document.location.protocol.length));
    window.location.href = url;
}
