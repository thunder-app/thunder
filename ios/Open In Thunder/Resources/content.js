let instances = [
    "bin.pol.social",
    "fedia.io",
    "kbin.chat",
    "kbin.spritesserver.nl",
    "polesie.pol.social",
    "thebrainbin.org",
    "whatco.me",
    "0xdd.org.ru",
    "1337lemmy.com",
    "13mmy.io",
    "7.62x54r.ru",
    "acqrs.co.uk",
    "adultswim.fan",
    "aggregatet.org",
    "alien.top",
    "ani.social",
    "ascy.mooo.com",
    "aussie.zone",
    "awful.systems",
    "azgil.net",
    "badatbeing.social",
    "baraza.africa",
    "bbs.9tail.net",
    "beehaw.org",
    "belfry.rip",
    "beta.programming.dev",
    "biglemmowski.win",
    "bin.pztrn.name",
    "bitforged.space",
    "blendit.bsd.cafe",
    "board.minimally.online",
    "bolha.forum",
    "bookwormstory.social",
    "borg.chat",
    "botnet.club",
    "bulletintree.com",
    "cafe.rafled.com",
    "campfyre.nickwebster.dev",
    "casavaga.com",
    "catata.fish",
    "champserver.net",
    "chinese.lol",
    "civilloquy.com",
    "communick.news",
    "corndog.social",
    "corrigan.space",
    "cyberpaws.lol",
    "dendarii.alaeron.com",
    "dev.automationwise.com",
    "diagonlemmy.social",
    "digipres.cafe",
    "discover.deltanauten.de",
    "discuss.icewind.me",
    "discuss.jacen.moe",
    "discuss.online",
    "discuss.tchncs.de",
    "distress.digital",
    "dit.reformed.social",
    "doomscroll.n8e.dev",
    "dormi.zone",
    "drlemmy.net",
    "dubvee.org",
    "endlesstalk.org",
    "europa.cyberveins.eu",
    "eventfrontier.com",
    "eviltoast.org",
    "expats.zone",
    "falconry.party",
    "fanaticus.social",
    "fasheng.ing",
    "fed.dyne.org",
    "feddit.cl",
    "feddit.dk",
    "feddit.eu",
    "feddit.it",
    "feddit.nl",
    "feddit.nu",
    "feddit.org",
    "feddit.rocks",
    "feddit.site",
    "feddit.uk",
    "federation.red",
    "fedii.me",
    "fedit.pl",
    "feditown.com",
    "feed.newt.wtf",
    "femboys.bar",
    "fenmou.cyou",
    "fjdk.uk",
    "fl0w.cc",
    "flamewar.social",
    "foros.fediverso.gal",
    "forum.ayom.media",
    "forum.penclub.club",
    "forum.uncomfortable.business",
    "fry.gs",
    "futurology.today",
    "gearhead.town",
    "gioia.news",
    "glass.casa",
    "gregtech.eu",
    "group.lt",
    "h4x0r.host",
    "hackertalks.com",
    "halubilo.social",
    "happysl.app",
    "hardware.watch",
    "hexbear.net",
    "hilariouschaos.com",
    "hobbit.world",
    "hoihoi.superboi.eu.org",
    "hyperfair.link",
    "info.prou.be",
    "infosec.pub",
    "jlai.lu",
    "kbin.thicknahalf.com",
    "krabb.org",
    "kulupu.duckdns.org",
    "kutsuya.dev",
    "kuu.kohana.fi",
    "kyu.de",
    "l.60228.dev",
    "l.7rg1nt.moe",
    "l.dongxi.ca",
    "l.henlo.fi",
    "l.mathers.fr",
    "l.mchome.net",
    "l.os33.co",
    "l.roofo.cc",
    "l.shoddy.site",
    "l.sw0.com",
    "l.vidja.social",
    "l3mmy.com",
    "lazysoci.al",
    "le.fduck.net",
    "le.weme.wtf",
    "leaf.dance",
    "lebowski.social",
    "lef.li",
    "leftopia.org",
    "lem.a3a2.uk",
    "lem.cochrun.xyz",
    "lem.darkmyre.cloud",
    "lem.free.as",
    "lem.monster",
    "lem.nimmog.uk",
    "lem.ph3j.com",
    "lem.sabross.xyz",
    "lem.serkozh.me",
    "lem.trashbrain.org",
    "lem.ur-mom.gay",
    "lemdro.id",
    "leminal.space",
    "lemm.ee",
    "lemmings.sopelj.ca",
    "lemmings.world",
    "lemmit.online",
    "lemmus.org",
    "lemmy-api.ten4ward.social",
    "lemmy.0upti.me",
    "lemmy.100010101.xyz",
    "lemmy.4rs.nl",
    "lemmy.86thumbs.net",
    "lemmy.8bitar.io",
    "lemmy.8th.world",
    "lemmy.absolutesix.com",
    "lemmy.activitypub.academy",
    "lemmy.ahall.se",
    "lemmy.aisteru.ch",
    "lemmy.amxl.com",
    "lemmy.ananace.dev",
    "lemmy.anonion.social",
    "lemmy.antisocial.ly",
    "lemmy.asc6.org",
    "lemmy.autism.place",
    "lemmy.azamserver.com",
    "lemmy.baie.me",
    "lemmy.balamb.fr",
    "lemmy.belegost.net",
    "lemmy.beru.co",
    "lemmy.best",
    "lemmy.bestiver.se",
    "lemmy.bit-refined.eu",
    "lemmy.bitgoblin.tech",
    "lemmy.blahaj.zone",
    "lemmy.blugatch.tube",
    "lemmy.bmck.au",
    "lemmy.bothhands.ca",
    "lemmy.brad.ee",
    "lemmy.bran.ink",
    "lemmy.brdsnest.net",
    "lemmy.browntown.dev",
    "lemmy.byrdcrouse.com",
    "lemmy.byteunion.com",
    "lemmy.ca",
    "lemmy.cafe",
    "lemmy.caliban.io",
    "lemmy.calvss.com",
    "lemmy.cesarnogueira.com",
    "lemmy.ch3n2k.com",
    "lemmy.chaos.berlin",
    "lemmy.chiisana.net",
    "lemmy.chrisco.me",
    "lemmy.cnschn.com",
    "lemmy.co.nz",
    "lemmy.cogindo.net",
    "lemmy.comfysnug.space",
    "lemmy.coupou.fr",
    "lemmy.crimedad.work",
    "lemmy.cringecollective.io",
    "lemmy.criticalbasics.xyz",
    "lemmy.croc.pw",
    "lemmy.cronyakatsuki.xyz",
    "lemmy.cryonex.net",
    "lemmy.csupes.page",
    "lemmy.cultimean.group",
    "lemmy.davidfreina.at",
    "lemmy.dbzer0.com",
    "lemmy.death916.xyz",
    "lemmy.decronym.xyz",
    "lemmy.deedium.nl",
    "lemmy.demonoftheday.eu",
    "lemmy.despotes.nl",
    "lemmy.dev.sebathefox.dk",
    "lemmy.digitalcharon.in",
    "lemmy.digitalfall.net",
    "lemmy.discothe.quest",
    "lemmy.doesnotexist.club",
    "lemmy.dogboy.xyz",
    "lemmy.dominikoso.me",
    "lemmy.doomeer.com",
    "lemmy.dropdoos.nl",
    "lemmy.duck.cafe",
    "lemmy.dynatron.me",
    "lemmy.eatsleepcode.ca",
    "lemmy.eco.br",
    "lemmy.emerald.show",
    "lemmy.emphisia.nl",
    "lemmy.enchanted.social",
    "lemmy.eus",
    "lemmy.evangineer.net",
    "lemmy.federate.cc",
    "lemmy.federate.lol",
    "lemmy.fedi.zutto.fi",
    "lemmy.fedifriends.social",
    "lemmy.fish",
    "lemmy.fornaxian.tech",
    "lemmy.fosshost.com",
    "lemmy.foxden.party",
    "lemmy.freewilltiger.page",
    "lemmy.fromshado.ws",
    "lemmy.frozeninferno.xyz",
    "lemmy.funami.tech",
    "lemmy.fwgx.uk",
    "lemmy.glasgow.social",
    "lemmy.graphics",
    "lemmy.greatpyramid.social",
    "lemmy.grys.it",
    "lemmy.gwa.app",
    "lemmy.hacktheplanet.be",
    "lemmy.haley.io",
    "lemmy.halfbro.xyz",
    "lemmy.helheim.net",
    "lemmy.helios42.de",
    "lemmy.helvetet.eu",
    "lemmy.hogru.ch",
    "lemmy.horwood.cloud",
    "lemmy.hosted.frl",
    "lemmy.hybridsarcasm.xyz",
    "lemmy.imagisphe.re",
    "lemmy.inbutts.lol",
    "lemmy.installation00.org",
    "lemmy.institute",
    "lemmy.itsallbadsyntax.com",
    "lemmy.iys.io",
    "lemmy.jacaranda.club",
    "lemmy.jackson.dev",
    "lemmy.jamesj999.co.uk",
    "lemmy.janiak.cc",
    "lemmy.javant.xyz",
    "lemmy.jaypg.pw",
    "lemmy.jhjacobs.nl",
    "lemmy.jimbosfiles.com",
    "lemmy.jlh.name",
    "lemmy.jmtr.org",
    "lemmy.jnks.xyz",
    "lemmy.johnnei.org",
    "lemmy.jonaharagon.net",
    "lemmy.kaytse.fun",
    "lemmy.kde.social",
    "lemmy.keychat.org",
    "lemmy.kfed.org",
    "lemmy.killtime.online",
    "lemmy.klein.ruhr",
    "lemmy.kmoneyserver.com",
    "lemmy.ko4abp.com",
    "lemmy.kopieczek.com",
    "lemmy.korgen.xyz",
    "lemmy.kwain.net",
    "lemmy.kya.moe",
    "lemmy.laitinlok.com",
    "lemmy.lantian.pub",
    "lemmy.libertarianfellowship.org",
    "lemmy.libreprime.io",
    "lemmy.linden.social",
    "lemmy.linuxuserspace.show",
    "lemmy.lukeog.com",
    "lemmy.lundgrensjostrom.com",
    "lemmy.magnor.ovh",
    "lemmy.masto.community",
    "lemmy.max-p.me",
    "lemmy.mbl.social",
    "lemmy.mebitek.com",
    "lemmy.meissners.me",
    "lemmy.menf.in",
    "lemmy.mengsk.org",
    "lemmy.menos.gotdns.org",
    "lemmy.michaelsasser.org",
    "lemmy.mindoki.com",
    "lemmy.minecloud.ro",
    "lemmy.minetest.ch",
    "lemmy.minie4.de",
    "lemmy.minigubben.se",
    "lemmy.mkwarman.com",
    "lemmy.ml",
    "lemmy.mlaga97.space",
    "lemmy.mods4ever.com",
    "lemmy.monster",
    "lemmy.moocloud.party",
    "lemmy.moonling.nl",
    "lemmy.mrm.one",
    "lemmy.mrrl.me",
    "lemmy.muffalings.com",
    "lemmy.multivers.cc",
    "lemmy.mws.rocks",
    "lemmy.my-box.dev",
    "lemmy.myserv.one",
    "lemmy.nannoda.com",
    "lemmy.nauk.io",
    "lemmy.ndlug.org",
    "lemmy.nekusoul.de",
    "lemmy.nerdcore.social",
    "lemmy.nicknakin.com",
    "lemmy.nine-hells.net",
    "lemmy.noellesporn.de",
    "lemmy.nope.ly",
    "lemmy.norbipeti.eu",
    "lemmy.notmy.cloud",
    "lemmy.nowhere.moe",
    "lemmy.nowsci.com",
    "lemmy.nuage-libre.fr",
    "lemmy.nyc.what.if.ua",
    "lemmy.nz",
    "lemmy.obrell.se",
    "lemmy.ohaa.xyz",
    "lemmy.okr765.com",
    "lemmy.oldtr.uk",
    "lemmy.one",
    "lemmy.onlylans.io",
    "lemmy.packitsolutions.net",
    "lemmy.parastor.net",
    "lemmy.pe1uca.dev",
    "lemmy.peoplever.se",
    "lemmy.physfluids.fr",
    "lemmy.pierre-couy.fr",
    "lemmy.pit.ninja",
    "lemmy.platypush.tech",
    "lemmy.procrastinati.org",
    "lemmy.prograhamming.com",
    "lemmy.pt",
    "lemmy.pubsub.fun",
    "lemmy.pussthecat.org",
    "lemmy.radio",
    "lemmy.ramble.moe",
    "lemmy.razbot.xyz",
    "lemmy.remotelab.uk",
    "lemmy.remoteplay.im",
    "lemmy.reysic.com",
    "lemmy.rhymelikedi.me",
    "lemmy.rhys.wtf",
    "lemmy.rochegmr.com",
    "lemmy.run",
    "lemmy.runesmite.com",
    "lemmy.safe-internet.org",
    "lemmy.saik0.com",
    "lemmy.sarcasticdeveloper.com",
    "lemmy.schlunker.com",
    "lemmy.schoenwolf-schroeder.com",
    "lemmy.sdf.org",
    "lemmy.sebbem.se",
    "lemmy.secnd.me",
    "lemmy.self-hosted.site",
    "lemmy.services.coupou.fr",
    "lemmy.setzman.synology.me",
    "lemmy.shiny-task.com",
    "lemmy.shtuf.eu",
    "lemmy.sidh.bzh",
    "lemmy.sieprawski.pl",
    "lemmy.sietch.online",
    "lemmy.simpl.website",
    "lemmy.skoops.social",
    "lemmy.skyjake.fi",
    "lemmy.smay.dev",
    "lemmy.snoot.tube",
    "lemmy.socdojo.com",
    "lemmy.sotu.casa",
    "lemmy.spacestation14.com",
    "lemmy.specksick.com",
    "lemmy.ssba.com",
    "lemmy.stad.social",
    "lemmy.staphup.nl",
    "lemmy.starlightkel.xyz",
    "lemmy.stefanoprenna.com",
    "lemmy.stonansh.org",
    "lemmy.stuart.fun",
    "lemmy.studio",
    "lemmy.sumuun.net",
    "lemmy.sysctl.io",
    "lemmy.t-rg.ws",
    "lemmy.tario.org",
    "lemmy.team",
    "lemmy.technosorcery.net",
    "lemmy.techtailors.net",
    "lemmy.techtriage.guru",
    "lemmy.telaax.com",
    "lemmy.tellyou.social",
    "lemmy.tespia.org",
    "lemmy.tetricz.com",
    "lemmy.teuto.icu",
    "lemmy.tgxn.net",
    "lemmy.thebias.nl",
    "lemmy.thefloatinglab.world",
    "lemmy.thenewgaming.de",
    "lemmy.thesanewriter.com",
    "lemmy.thewooskeys.com",
    "lemmy.titanplusplus.online",
    "lemmy.tobyvin.dev",
    "lemmy.today",
    "lemmy.toldi.eu",
    "lemmy.tomaz.me",
    "lemmy.toot.pt",
    "lemmy.tr00st.co.uk",
    "lemmy.trevor.coffee",
    "lemmy.trippy.pizza",
    "lemmy.ubergeek77.chat",
    "lemmy.uhhoh.com",
    "lemmy.umucat.day",
    "lemmy.unboiled.info",
    "lemmy.unfiltered.social",
    "lemmy.uninsane.org",
    "lemmy.unryzer.eu",
    "lemmy.urbanhost.top",
    "lemmy.va-11-hall-a.cafe",
    "lemmy.vg",
    "lemmy.vyizis.tech",
    "lemmy.w9r.de",
    "lemmy.wentam.net",
    "lemmy.whynotdrs.org",
    "lemmy.works",
    "lemmy.world",
    "lemmy.wtf",
    "lemmy.xeviousx.eu",
    "lemmy.xoynq.com",
    "lemmy.xxxiver.se",
    "lemmy.yachts",
    "lemmy.z0r.co",
    "lemmy.zhukov.al",
    "lemmy.zimage.com",
    "lemmy.zip",
    "lemmy.zwanenburg.info",
    "lemmyf.uk",
    "lemmyfi.com",
    "lemmygrad.ml",
    "lemmyis.fun",
    "lemmyland.com",
    "lemmynsfw.com",
    "lemmys.hivemind.at",
    "lemux.minnix.dev",
    "lemy.leuker.me",
    "lemy.lol",
    "lemy.nl",
    "level-up.zone",
    "libretechni.ca",
    "liminal.southfox.me",
    "linkage.ds8.zone",
    "links.gayfr.online",
    "links.hackliberty.org",
    "links.rocks",
    "links.roobre.es",
    "linux.community",
    "linz.city",
    "literature.cafe",
    "lm.boing.icu",
    "lm.inu.is",
    "lm.korako.me",
    "lm.madiator.cloud",
    "lm.paradisus.day",
    "lm.sethp.cc",
    "lmmy.dk",
    "lmy.brx.io",
    "lmy.sagf.io",
    "lonestarlemmy.mooo.com",
    "lsmu.schmurian.xyz",
    "lu.skbo.net",
    "lululemmy.com",
    "lx.pontual.social",
    "mander.xyz",
    "martinlm.now-dns.net",
    "metapowers.org",
    "midwest.social",
    "mimiclem.me",
    "mlem.hackular.com",
    "monero.town",
    "monyet.cc",
    "moose.best",
    "moto.teamswollen.org",
    "mtgzone.com",
    "mujico.org",
    "natur.23.nu",
    "new-reddit.jinomial.com",
    "news.cosocial.ca",
    "news.idlestate.org",
    "nexxis.social",
    "no.lastname.nz",
    "nodesphere.site",
    "notdigg.com",
    "nsfwaiclub.com",
    "odin.lanofthedead.xyz",
    "orbiting.observer",
    "orcas.enjoying.yachts",
    "overctrl.dbzer0.com",
    "parenti.sh",
    "pasta.faith",
    "pawb.social",
    "ponder.cat",
    "popplesburger.hilciferous.nl",
    "poptalk.scrubbles.tech",
    "possumpat.io",
    "posta.no",
    "precious.net",
    "preserve.games",
    "pricefield.org",
    "programming.dev",
    "proit.org",
    "quokk.au",
    "r-sauna.fi",
    "r.nf",
    "radiation.party",
    "rblind.com",
    "real.lemmy.fan",
    "reddeet.com",
    "reddit.moonbeam.town",
    "reddrefuge.com",
    "reddthat.com",
    "rekabu.ru",
    "rentadrunk.org",
    "retrolemmy.com",
    "roanoke.social",
    "rollenspiel.forum",
    "rqd2.net",
    "s.jape.work",
    "sammich.es",
    "scribe.disroot.org",
    "selfhosted.forum",
    "seriously.iamincredibly.gay",
    "sffa.community",
    "sh.itjust.works",
    "sha1.nl",
    "showeq.com",
    "slangenettet.pyjam.as",
    "slrpnk.net",
    "soc.ebmn.io",
    "soccer.forum",
    "social.belowland.com",
    "social.bug.expert",
    "social.dn42.us",
    "social.ggbox.fr",
    "social.jears.at",
    "social.nerdhouse.io",
    "social.p80.se",
    "social.packetloss.gg",
    "social.rocketsfall.net",
    "social.sour.is",
    "social2.williamyam.com",
    "sopuli.xyz",
    "spgrn.com",
    "stammtisch.hallertau.social",
    "startrek.website",
    "sub.wetshaving.social",
    "supernova.place",
    "suppo.fi",
    "support.futbol",
    "swg-empire.de",
    "switter.su",
    "t.bobamilktea.xyz",
    "tacobu.de",
    "the.unknowing.dance",
    "theculture.social",
    "thelemmy.club",
    "timesink.p3nguin.org",
    "tkohhh.social",
    "tldr.ar",
    "toast.ooo",
    "ttrpg.network",
    "tucson.social",
    "ukfli.uk",
    "unreachable.cloud",
    "upvote.au",
    "usenet.lol",
    "va11halla.bar",
    "vegantheoryclub.org",
    "vger.social",
    "welppp.com",
    "whemic.xyz",
    "wired.bluemarch.art",
    "xn--mh-fkaaaaaa.schuetze.link",
    "yall.theatl.social",
    "yamasaur.com",
    "yiffit.net",
    "ythreektech.com",
    "zerobytes.monster",
    "zoo.splitlinux.org"
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
