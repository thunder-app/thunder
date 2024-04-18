let instances = [
    "ani.social",
    "aussie.zone",
    "awful.systems",
    "beehaw.org",
    "burggit.moe",
    "discuss.online",
    "discuss.tchncs.de",
    "feddit.dk",
    "feddit.it",
    "feddit.nl",
    "feddit.nu",
    "feddit.uk",
    "hexbear.net",
    "infosec.pub",
    "iusearchlinux.fyi",
    "jlai.lu",
    "lemdro.id",
    "leminal.space",
    "lemm.ee",
    "lemmings.world",
    "lemmy.blahaj.zone",
    "lemmy.ca",
    "lemmy.dbzer0.com",
    "lemmy.eco.br",
    "lemmy.kya.moe",
    "lemmy.ml",
    "lemmy.nz",
    "lemmy.one",
    "lemmy.sdf.org",
    "lemmy.today",
    "lemmy.world",
    "lemmy.zip",
    "lemmygrad.ml",
    "lemmynsfw.com",
    "lemy.lol",
    "lululemmy.com",
    "mander.xyz",
    "midwest.social",
    "monero.town",
    "pawb.social",
    "programming.dev",
    "reddthat.com",
    "sh.itjust.works",
    "slrpnk.net",
    "sopuli.xyz",
    "startrek.website",
    "szmer.info",
    "thelemmy.club",
    "ttrpg.network",
    "yiffit.net"
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
