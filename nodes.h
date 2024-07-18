#include <iostream>
#include <vector>
#include <map>
#include <set>

using namespace std;

extern char *build_file_name;
extern int yylineno;
int errorcount = 0;

class Node {
protected:
    int lineno;

public:
    vector<Node *> children;
    Node() {
        lineno = yylineno;
    }
    int getLineNo() {
        return lineno;
    }
    virtual string getType() {
        return " ";
    }
    virtual string toStr() {
        return "stmts";
    }
    void append(Node *n) {
        children.push_back(n);
    }
    vector<Node *> &getChildren() {
        return children;
    }
};

class Program : public Node {
public:
    virtual string toStr() {
        return "Program";
    }
};

class Integer : public Node {
protected:
    int value;

public:
    Integer(const int v) {
        value = v;
    }
    virtual string getType() override {
        return "Int";
    }

    virtual string toStr() override {
        return to_string(value);
    }
};

class Float : public Node {
protected:
    float value;

public:
    Float(const float v) {
        value = v;
    }
    virtual string getType() override {
        return "Float";
    }
    virtual string toStr() override {
        return to_string(value);
    }
};

class Bool : public Node {
protected:
    bool value;

public:
    Bool(const bool v) {
        value = v;
    }
    virtual string getType() override {
        return "Bool";
    }
    virtual bool getValue() {
        return value;
    }
    virtual string toStr() override {
        if (value) {
            return "True";
        }
        else {
            return "False";
        }
    }
};

class String : public Node {
protected:
    string frase;

public:
    String(string v) {
        frase = v;
    }
    virtual string getType() override {
        return "String";
    }
    virtual string getFrase() {
        return frase;
    }
    virtual string toStr() override {
        string a = frase;
        a.pop_back();
        string aux = string("\\") + a + string("\\\"");
        return aux;
    }
};

class Loop : public Node {
protected:
    Node *condition;
    Node *content;

public:
    Loop(Node *c, Node *n) {
        content = n;
        condition = c;
        children.push_back(c);
        children.push_back(n);
    }
    virtual Node *getCondition() {
        return condition;
    }

    virtual string toStr() override {
        return "Loop";
    }
};

class Ifso : public Node {
protected:
    Node *condition;
    Node *content;

public:
    Ifso(Node *c, Node *n) {
        condition = c;
        content = n;
        children.push_back(c);
        children.push_back(n);
    }

    virtual Node *getCondition() {
        return condition;
    }

    virtual string toStr() override {
        return "If so";
    }
};

class Ifnot : public Node {
protected:
    Node *contentIfso;
    Node *contentIfnot;
    Node *condition;

public:
    Ifnot(Node *c, Node *s, Node *sn) {
        condition = c;
        contentIfso = s;
        contentIfnot = sn;
        children.push_back(c);
        children.push_back(s);
        children.push_back(sn);
    }

    virtual Node *getCondition() {
        return condition;
    }
    virtual string toStr() override {
        return "If not";
    }
};

class Ident : public Node {
protected:
    string name;

public:
    Ident(const string n) {
        name = n;
    }

    virtual string getName() {
        return name;
    }

    virtual string getType() {
        return "Ident";
    }

    virtual string toStr() override {
        return name;
    }
};

class Variable : public Node {
protected:
    string name;
    Node *value;

public:
    Variable(const string n, Node *v) {
        name = n;
        value = v;
        children.push_back(v);
    }

    virtual Node *getNode() {
        return value;
    }

    virtual string getName() {
        return name;
    }

    virtual string toStr() override {
        return name + " =";
    }
};

class Unary : public Node {
protected:
    Node *value;
    string operation;

public:
    Unary(string op, Node *v) {
        value = v;
        operation = op;
        children.push_back(v);
    }
    virtual Node *getNode() {
        return value;
    }
    virtual string getType() {
        return value->getType();
    }
    virtual string toStr() override {
        return operation;
    }
};

class BinaryOp : public Node {
protected:
    Node *value1;
    Node *value2;
    string operation;

public:
    BinaryOp(Node *v1, char op, Node *v2) {
        value1 = v1;
        value2 = v2;
        operation = op;
        children.push_back(v1);
        children.push_back(v2);
    }

    virtual Node *getNode1() {
        return value1;
    }

    virtual Node *getNode2() {
        return value2;
    }
    virtual string getOperation() {
        return operation;
    }

    virtual string toStr() override {
        return operation;
    }
};

class Print : public Node {
protected:
    Node *value;

public:
    Print(Node *v) {
        value = v;
        children.push_back(v);
    }

    virtual string toStr() {
        return "Print";
    }
};

void printf_tree_recursive(Node *noh) {
    for (Node *c : noh->getChildren()) {
        printf_tree_recursive(c);
    }
    cout << "N" << (long int)noh << "[label=\"" << noh->toStr() << "\"];" << endl;

    for (Node *c : noh->getChildren()) {
        cout << "N" << (long int)noh << "--" << "N" << (long int)c << ";" << endl;
    }
}

void printf_tree(Node *root) {
    cout << "graph {" << endl;
    printf_tree_recursive(root);
    cout << "}" << endl;
}

class CheckVarDecl {
private:
    set<string> symbolsInt, symbolsFloat, symbolsBol, symbolsStr;

public:
    CheckVarDecl() {}

    void check(Node *noh) {
        for (Node *c : noh->getChildren()) {
            checkUnaryString(noh);
            checkUnaryBolean(noh);
            if (dynamic_cast<BinaryOp *>(c)) {
                CheckBinaryOp(c);
            }
            check(c);
        }

        Ifso *ifso = dynamic_cast<Ifso *>(noh);
        if (ifso) {
            checkStringCondition(ifso->getCondition());
            return;
        }
        Loop *loop = dynamic_cast<Loop *>(noh);
        if (loop) {
            checkStringCondition(loop->getCondition());
            return;
        }

        Ifnot *ifnot = dynamic_cast<Ifnot *>(noh);
        if (ifnot) {
            checkStringCondition(ifnot->getCondition());
            return;
        }

        Ident *ident = dynamic_cast<Ident *>(noh);
        if (ident) {
            if (symbolsInt.count(ident->getName()) <= 0 &&
                symbolsFloat.count(ident->getName()) <= 0 &&
                symbolsBol.count(ident->getName()) <= 0 &&
                symbolsStr.count(ident->getName()) <= 0) {
                errorcount++;
                cout << build_file_name
                     << " "
                     << ident->getLineNo()
                     << ":0: Erro Semântico: "
                     << ident->getName()
                     << " Não definido!."
                     << endl;
            }
        }

        Variable *variable = dynamic_cast<Variable *>(noh);
        if (variable) {
            Node *n = variable->getNode();
            if (dynamic_cast<Integer *>(n)) {
                symbolsInt.insert(variable->getName());
                return;
            }
            if (dynamic_cast<Float *>(n)) {
                symbolsFloat.insert(variable->getName());
                return;
            }
            if (dynamic_cast<String *>(n)) {
                symbolsStr.insert(variable->getName());
                return;
            }
            if (dynamic_cast<Bool *>(n)) {
                symbolsBol.insert(variable->getName());
                return;
            }

            Ident *ident = dynamic_cast<Ident *>(n);
            if (ident) {
                if (symbolsInt.count(ident->getName()) != 0) {
                    symbolsInt.insert(variable->getName());
                    return;
                }
                if (symbolsFloat.count(ident->getName()) != 0) {
                    symbolsFloat.insert(variable->getName());
                    return;
                }
                if (symbolsStr.count(ident->getName()) != 0) {
                    symbolsStr.insert(variable->getName());
                    return;
                }
                if (symbolsBol.count(ident->getName()) != 0) {
                    symbolsBol.insert(variable->getName());
                    return;
                }
            }

            BinaryOp *aux, *opb = dynamic_cast<BinaryOp *>(n);
            while (opb != NULL) {
                aux = opb;
                opb = dynamic_cast<BinaryOp *>(opb->getNode1());
            }

            Node *n1 = aux->getNode1();
            if (dynamic_cast<Integer *>(n1)) {
                symbolsInt.insert(variable->getName());
                return;
            }
            if (dynamic_cast<Float *>(n1)) {
                symbolsFloat.insert(variable->getName());
                return;
            }
            if (dynamic_cast<String *>(n1)) {
                symbolsStr.insert(variable->getName());
                return;
            }
            if (dynamic_cast<Bool *>(n1)) {
                symbolsBol.insert(variable->getName());
                return;
            }

            ident = dynamic_cast<Ident *>(n1);
            if (ident) {
                if (symbolsInt.count(ident->getName()) != 0) {
                    symbolsInt.insert(variable->getName());
                    return;
                }
                if (symbolsFloat.count(ident->getName()) != 0) {
                    symbolsFloat.insert(variable->getName());
                    return;
                }
                if (symbolsStr.count(ident->getName()) != 0) {
                    symbolsStr.insert(variable->getName());
                    return;
                }
                if (symbolsBol.count(ident->getName()) != 0) {
                    symbolsBol.insert(variable->getName());
                    return;
                }
            }

            Unary *aun, *un = dynamic_cast<Unary *>(n);

            if (un) {
                while (un != NULL) {
                    aun = un;
                    un = dynamic_cast<Unary *>(un->getNode());
                }

                Node *aunn = aun->getNode();
                if (dynamic_cast<Integer *>(aunn)) {
                    symbolsInt.insert(variable->getName());
                    return;
                }
                if (dynamic_cast<Float *>(aunn)) {
                    symbolsFloat.insert(variable->getName());
                    return;
                }
                if (dynamic_cast<String *>(aunn)) {
                    symbolsStr.insert(variable->getName());
                    return;
                }
                if (dynamic_cast<Bool *>(aunn)) {
                    symbolsBol.insert(variable->getName());
                    return;
                }

                Ident *uident = dynamic_cast<Ident *>(aunn);
                if (uident) {
                    if (symbolsInt.count(uident->getName()) != 0) {
                        symbolsInt.insert(variable->getName());
                        return;
                    }
                    if (symbolsFloat.count(uident->getName()) != 0) {
                        symbolsFloat.insert(variable->getName());
                        return;
                    }
                    if (symbolsStr.count(uident->getName()) != 0) {
                        symbolsStr.insert(variable->getName());
                        return;
                    }
                    if (symbolsBol.count(uident->getName()) != 0) {
                        symbolsBol.insert(variable->getName());
                        return;
                    }
                }
            }
        }
    }

    void checkStringCondition(Node *noh) {

        Ident *ident = dynamic_cast<Ident *>(noh);
        if (ident) {
            if (symbolsStr.count(ident->getName()) == 1) {
                errorcount++;
                cout << build_file_name
                     << " "
                     << ident->getLineNo()
                     << ":0: Erro semântico: "
                     << "Não use apenas uma variável do tipo [String] em uma Condição"
                     << endl;
                return;
            }
        }

        String *p = dynamic_cast<String *>(noh);
        if (p) {
            errorcount++;
            cout << build_file_name
                 << " "
                 << p->getLineNo()
                 << ":0: Erro semântico: "
                 << "Não use apenas uma variável do tipo [String] em uma Condição"
                 << endl;
            return;
        }
    }

    void checkUnaryString(Node *noh) {
        int n_toDelete = 0;

        for (Node *c : noh->getChildren()) {
            Unary *un = dynamic_cast<Unary *>(c);

            if (un) {
                Unary *aux;
                for (Unary *un1 = dynamic_cast<Unary *>(un);
                     un1;
                     aux = un1, un1 = dynamic_cast<Unary *>(un1->getNode()))
                    ;

                String *p = dynamic_cast<String *>(aux->getNode());
                if (p) {
                    noh->children.push_back(new String(p->getFrase()));
                    noh->children.erase(noh->children.begin() + n_toDelete);
                }
            }
            n_toDelete++;
        }
    }

    void checkUnaryBolean(Node *noh) {
        int n_toDelete = 0;

        for (Node *c : noh->getChildren()) {
            Unary *un = dynamic_cast<Unary *>(c);

            if (un) {
                Unary *aux;
                for (Unary *un1 = dynamic_cast<Unary *>(un);
                     un1;
                     aux = un1, un1 = dynamic_cast<Unary *>(un1->getNode()))
                    ;

                Bool *b = dynamic_cast<Bool *>(aux->getNode());
                if (b) {
                    noh->children.push_back(new Bool(b->getValue()));
                    noh->children.erase(noh->children.begin() + n_toDelete);
                }
            }
            n_toDelete++;
        }
    }

    string getNameNode(Node *noh) {
        Unary *un = dynamic_cast<Unary *>(noh);
        if (un) {
            return getNameNode(un->getNode());
        }
        Ident *ident = dynamic_cast<Ident *>(noh);
        if (ident) {
            if (symbolsInt.count(ident->getName()) != 0) {
                return "Integer";
            }
            if (symbolsFloat.count(ident->getName()) != 0) {
                return "Float";
            }
            if (symbolsBol.count(ident->getName()) != 0) {
                return "Bool";
            }
            if (symbolsStr.count(ident->getName()) != 0) {
                return "String";
            }
        }

        if (dynamic_cast<Integer *>(noh)) {
            return "Integer";
        }
        if (dynamic_cast<Float *>(noh)) {
            return "Float";
        }
        if (dynamic_cast<Bool *>(noh)) {
            return "Bool";
        }
        if (dynamic_cast<String *>(noh)) {
            return "String";
        }

        BinaryOp *opb = dynamic_cast<BinaryOp *>(noh);
        if (opb) {
            return string(getNameNode(opb->getNode1()) + " " + opb->getOperation() + " " + getNameNode(opb->getNode2()));
        }

        return " ";
    }

    int CheckBinaryOp(Node *noh) {
        Node *aux = noh;
        Unary *un = dynamic_cast<Unary *>(noh);
        if (un) {
            return CheckBinaryOp(un->getNode());
        }

        if (dynamic_cast<Integer *>(aux)) {
            return 0;
        }
        if (dynamic_cast<Float *>(aux)) {
            return 1;
        }
        if (dynamic_cast<Bool *>(aux)) {
            return 2;
        }
        if (dynamic_cast<String *>(aux)) {
            return 3;
        }

        Ident *ident = dynamic_cast<Ident *>(aux);

        if (ident) {
            if (symbolsInt.count(ident->getName()) != 0) {
                return 0;
            }
            if (symbolsFloat.count(ident->getName()) != 0) {
                return 1;
            }
            if (symbolsBol.count(ident->getName()) != 0) {
                return 3;
            }
            if (symbolsStr.count(ident->getName()) != 0) {
                return 4;
            }
        }

        BinaryOp *ob = dynamic_cast<BinaryOp *>(noh);
        if (ob) {
            if (CheckBinaryOp(ob->getNode1()) != CheckBinaryOp(ob->getNode2())) {
                errorcount++;
                cout << build_file_name
                     << " "
                     << ob->getLineNo()
                     << ":0: Erro Semântico:  Operações entre ["
                     << getNameNode(ob->getNode1())
                     << "] e ["
                     << getNameNode(ob->getNode2())
                     << "] não são válidas!"
                     << endl;
                return __INT_MAX__;
            }
            else {
                return CheckBinaryOp(ob->getNode1());
            }
        }
        return __INT_MAX__;
    }
};