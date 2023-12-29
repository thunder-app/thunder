let instances = [
    "aussie.zone",
    "awful.systems",
    "bakchodi.org",
    "beehaw.org",
    "burggit.moe",
    "dataterm.digital",
    "delraymisfitsboard.com",
    "discuss.online",
    "discuss.tchncs.de",
    "exploding-heads.com",
    "feddit.ch",
    "feddit.de",
    "feddit.dk",
    "feddit.it",
    "feddit.nl",
    "feddit.uk",
    "geddit.social",
    "hexbear.net",
    "infosec.pub",
    "iusearchlinux.fyi",
    "jlai.lu",
    "lemdro.id",
    "lemm.ee",
    "lemmings.world",
    "lemmus.org",
    "lemmy.blahaj.zone",
    "lemmy.ca",
    "lemmy.dbzer0.com",
    "lemmy.eco.br",
    "lemmy.fmhy.ml",
    "lemmy.kya.moe",
    "lemmy.ml",
    "lemmy.nz",
    "lemmy.one",
    "lemmy.sdf.org",
    "lemmy.today",
    "lemmy.whynotdrs.org",
    "lemmy.world",
    "lemmy.zip",
    "lemmygrad.ml",
    "lemmynsfw.com",
    "lemy.lol",
    "mander.xyz",
    "midwest.social",
    "monero.town",
    "pawb.social",
    "programming.dev",
    "reddthat.com",
    "sh.itjust.works",
    "slrpnk.net",
    "social.fossware.space",
    "sopuli.xyz",
    "startrek.website",
    "szmer.info",
    "ttrpg.network",
    "vlemmy.net",
    "waveform.social",
    "www.hexbear.net",
    "yiffit.net"
];

const observeUrlChange = () => {
    let oldHref = document.location.href;

    const body = document.querySelector("body");
    const observer = new MutationObserver((mutations) => {
        if (oldHref !== document.location.href) {
            oldHref = document.location.href;
            openInThunder();
        }
    });

    observer.observe(body, { childList: true, subtree: true });
};


function isLemmyInstance(arr) {
    const currentHost = new URL(document.location.href).host;

    for (let i = 0; i < instances.length; i++) {
        if (currentHost.includes(instances[i])) {
            return true;
        }
    }

    return false;
}

function openInThunder() {
    const shouldOpen = isLemmyInstance();
    if (!shouldOpen) return;

    let url = new URL(document.location.href);
    url.protocol = "thunder:";
    window.location.href = url;
}

openInThunder();
window.onload = observeUrlChange;
