# nodes.pp
#

node default {
}

node basenode {
}

node devel inherits basenode {
}

node prod inherits basenode {
}

node 'devagent1.alfa.local' inherits devel {
}

node 'win7user.localdomain' inherits prod  {
} 

node 'hudson.alfa.local' {
} 
