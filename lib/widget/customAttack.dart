import 'package:flutter/material.dart';

class CustomAttackFile extends StatelessWidget {
  final String image;
  final String name;
  final void Function()? onTap;
  const CustomAttackFile({super.key,required this.image,required this.name,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Column(children: [
          Container(
            decoration: BoxDecoration(color: Colors.green,
              borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover)),
            width: MediaQuery.of(context).size.width * .15,
            height: MediaQuery.of(context).size.height * .08,
          ),
          Text(name)
        ]),
    );
  }
}
