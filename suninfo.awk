# suninfo.awk --- simple program to civil sunrise twilight from
#                 http://www.earthtools.org/

BEGIN { FS="[<|>]" }
/morning/ {
  print $2
}
/evening/ {
  print $2
}
/sunset/  {
  print $3
}
/sunrise/  {
  print $3
}
/civil/ {
  print $3
}

