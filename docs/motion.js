/* =================================================================
   TripTalk — motion.js
   Progressive enhancement ONLY. The page is fully readable and
   usable with this file absent or JS disabled. Everything here is
   gated behind prefers-reduced-motion.
   ================================================================= */
(function () {
  "use strict";

  var root = document.documentElement;
  // Mark JS active so CSS can opt-in to the hero stagger without
  // hiding content for no-JS users.
  root.classList.add("js");

  var reduceMotion =
    window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* -------- Signature moment 1: hero kinetic type reveal -------- */
  var lines = Array.prototype.slice.call(
    document.querySelectorAll(".hero-display .line")
  );

  if (reduceMotion) {
    // Instant: just show everything.
    lines.forEach(function (l) { l.classList.add("is-set"); });
    revealAll();
  } else {
    // Stagger each hero line in, then cascade the supporting reveals.
    lines.forEach(function (line, i) {
      setTimeout(function () {
        line.classList.add("is-set");
      }, 140 + i * 170);
    });

    /* ---------- Scroll reveals via IntersectionObserver ---------- */
    if ("IntersectionObserver" in window) {
      var io = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              entry.target.classList.add("is-in");
              io.unobserve(entry.target);
            }
          });
        },
        { rootMargin: "0px 0px -10% 0px", threshold: 0.12 }
      );

      document.querySelectorAll("[data-reveal]").forEach(function (el) {
        io.observe(el);
      });

      // Safety net: if anything is still hidden after 4s (e.g. an
      // observer edge case, an element that never enters the
      // viewport), reveal it so content can never get stuck invisible.
      setTimeout(function () {
        document.querySelectorAll("[data-reveal]:not(.is-in)").forEach(
          function (el) {
            var r = el.getBoundingClientRect();
            if (r.top < window.innerHeight) el.classList.add("is-in");
          }
        );
      }, 4000);
    } else {
      revealAll();
    }
  }

  function revealAll() {
    document.querySelectorAll("[data-reveal]").forEach(function (el) {
      el.classList.add("is-in");
    });
  }

  /* -------- Subtle parallax drift on the hero bloom (cheap) ------ */
  if (!reduceMotion) {
    var bloom = document.querySelector(".hero-bloom");
    if (bloom && "requestAnimationFrame" in window) {
      var ticking = false;
      window.addEventListener(
        "scroll",
        function () {
          if (ticking) return;
          ticking = true;
          requestAnimationFrame(function () {
            var y = window.scrollY || 0;
            if (y < 900) {
              bloom.style.transform =
                "translateX(-50%) translateY(" + y * 0.12 + "px)";
            }
            ticking = false;
          });
        },
        { passive: true }
      );
    }
  }
})();
