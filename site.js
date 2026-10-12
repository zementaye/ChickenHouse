(function(){
  var b=document.querySelector('.burger'),n=document.getElementById('nav');
  if(b&&n){b.addEventListener('click',function(){var o=n.classList.toggle('open');b.setAttribute('aria-expanded',o)});}

  // Opening hours in Addis Ababa time (0 = Sunday). Keep in step with visit.html.
  var HOURS={0:[9,22],1:[8,22],2:[8,22],3:[8,22],4:[8,22],5:[8,23],6:[8,23]};
  var DAYS={Sun:0,Mon:1,Tue:2,Wed:3,Thu:4,Fri:5,Sat:6};
  function addisNow(){
    try{
      var p=new Intl.DateTimeFormat('en-US',{timeZone:'Africa/Addis_Ababa',weekday:'short',hour:'numeric',minute:'numeric',hourCycle:'h23'}).formatToParts(new Date()),o={};
      p.forEach(function(x){o[x.type]=x.value});
      return {day:DAYS[o.weekday],t:(+o.hour)+(+o.minute)/60};
    }catch(e){var d=new Date();return {day:d.getDay(),t:d.getHours()+d.getMinutes()/60};}
  }
  function fmt(h){return (h%12||12)+' '+(h>=12?'pm':'am');}
  var now=addisNow(),h=HOURS[now.day],open=now.t>=h[0]&&now.t<h[1],note=document.getElementById('openNote');
  if(note){
    var msg;
    if(open){msg=' Open now, until '+fmt(h[1]);}
    else{
      var nd=now.t<h[0]?now.day:(now.day+1)%7;
      msg=' Closed right now, opens '+(now.t<h[0]?'today':'tomorrow')+' at '+fmt(HOURS[nd][0]);
    }
    note.lastChild.textContent=msg;
    if(!open)document.body.classList.add('closed');
  }
  var row=document.querySelector('.hours tr[data-d="'+now.day+'"]');if(row)row.classList.add('today');

  // Pause the hero video for people who prefer reduced motion
  var v=document.querySelector('.hero video');
  if(v&&window.matchMedia('(prefers-reduced-motion: reduce)').matches){v.removeAttribute('autoplay');v.pause();}

  // Highlight the menu tab for the section in view
  var tabs=document.querySelectorAll('.board-tabs a');
  if(tabs.length&&'IntersectionObserver' in window){
    var io=new IntersectionObserver(function(es){es.forEach(function(e){if(e.isIntersecting){tabs.forEach(function(a){a.classList.toggle('on',a.getAttribute('href')==='#'+e.target.id)})}})},{rootMargin:'-30% 0px -60% 0px'});
    document.querySelectorAll('.cat').forEach(function(c){io.observe(c)});
  }
})();
