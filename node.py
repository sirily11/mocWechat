class Node:
    def __init__(self, content):
        self.content = content
        self.child = []
        self.type = None

    def hasChild(self):
        return len(self.child) > 0

    def addChild(self, child):
        self.child.append(child)
        return self

    def print(self):
        self.__print__(self)
        return self

    def __print__(self, nodes):
        if not nodes.hasChild():
            print(nodes.content)
            return
        print(self.content + "\n|")
        for node in nodes.child:
            node.__print__(node)


node = Node("a").addChild(Node("b").addChild(Node("d"))).addChild(Node("c"))
node.print()
