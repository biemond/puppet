# == Class: oradb
#
class oradb ($shout = true) {

  if $::oradb::shout {
    notify {"oradb init.pp":}  
  }

}
