let instances = [
    "ani.social",$'\n'    "aussie.zone",$'\n'    "bakchodi.org",$'\n'    "beehaw.org",$'\n'    "burggit.moe",$'\n'    "dataterm.digital",$'\n'    "delraymisfitsboard.com",$'\n'    "discuss.tchncs.de",$'\n'    "exploding-heads.com",$'\n'    "feddit.ch",$'\n'    "feddit.de",$'\n'    "feddit.dk",$'\n'    "feddit.it",$'\n'    "feddit.nl",$'\n'    "feddit.uk",$'\n'    "geddit.social",$'\n'    "hexbear.net",$'\n'    "infosec.pub",$'\n'    "iusearchlinux.fyi",$'\n'    "jlai.lu",$'\n'    "lemdro.id",$'\n'    "lemm.ee",$'\n'    "lemmings.world",$'\n'    "lemmus.org",$'\n'    "lemmy.blahaj.zone",$'\n'    "lemmy.ca",$'\n'    "lemmy.dbzer0.com",$'\n'    "lemmy.eco.br",$'\n'    "lemmy.fmhy.ml",$'\n'    "lemmy.kya.moe",$'\n'    "lemmy.ml",$'\n'    "lemmy.nz",$'\n'    "lemmy.one",$'\n'    "lemmy.sdf.org",$'\n'    "lemmy.today",$'\n'    "lemmy.whynotdrs.org",$'\n'    "lemmy.world",$'\n'    "lemmy.zip",$'\n'    "lemmygrad.ml",$'\n'    "lemmynsfw.com",$'\n'    "mander.xyz",$'\n'    "midwest.social",$'\n'    "monero.town",$'\n'    "pawb.social",$'\n'    "programming.dev",$'\n'    "reddthat.com",$'\n'    "sh.itjust.works",$'\n'    "slrpnk.net",$'\n'    "social.fossware.space",$'\n'    "sopuli.xyz",$'\n'    "startrek.website",$'\n'    "szmer.info",$'\n'    "ttrpg.network",$'\n'    "vlemmy.net",$'\n'    "waveform.social",$'\n'    "www.hexbear.net",$'\n'    "yiffit.net"
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
