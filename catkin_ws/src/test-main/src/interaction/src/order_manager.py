#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
语音点餐临时订单管理器。

说明：
1. 菜单优先来自数据库。
2. config/menu_aliases.yaml 仅用于补充语音别名。
3. 临时订单只保存在内存中。
4. 用户说“确认下单”后，订单才写入数据库。
"""

from typing import Any, Dict, List, Optional


class OrderManager:
    """临时订单管理器。"""

    def __init__(self, database_adapter, alias_data=None):
        self.database_adapter = database_adapter
        self.alias_data = alias_data or {}
        self.temp_order: List[Dict[str, Any]] = []
        self.menu_items: List[Dict[str, Any]] = []
        self.refresh_menu()

    def refresh_menu(self) -> None:
        """从数据库刷新菜单。"""
        self.menu_items = self.database_adapter.get_menu_items()
        self._apply_aliases()

    def _apply_aliases(self) -> None:
        """将 menu_aliases.yaml 中的别名补充到数据库菜单上。"""
        alias_map = self.alias_data.get("aliases", {}) if isinstance(self.alias_data, dict) else {}

        for item in self.menu_items:
            name = item.get("name", "")
            aliases = set(item.get("aliases", []))
            aliases.add(name)

            if name in alias_map:
                for alias in alias_map[name] or []:
                    aliases.add(alias)

            item["aliases"] = list(aliases)

    def get_menu_items(self) -> List[Dict[str, Any]]:
        return self.menu_items

    def find_menu_item(self, item_name: str) -> Optional[Dict[str, Any]]:
        item_name = (item_name or "").strip().replace(" ", "")
        if not item_name:
            return None

        for item in self.menu_items:
            names = [item.get("name", "")] + item.get("aliases", [])
            for cand in names:
                cand = (cand or "").replace(" ", "")
                if cand and (cand in item_name or item_name in cand):
                    return item

        return None

    def add_item(self, item_name: str, quantity: int, note: str = "") -> Dict[str, Any]:
        item = self.find_menu_item(item_name)

        if not item:
            return {
                "ok": False,
                "message": "菜单中没有这个菜品。",
            }

        if quantity <= 0:
            return {
                "ok": False,
                "message": "数量必须大于 0。",
            }

        existing = self._find_temp_item(item["name"])

        if existing:
            existing["quantity"] += quantity
            if note:
                existing["note"] = note
        else:
            self.temp_order.append(
                {
                    "item_id": item.get("item_id"),
                    "name": item["name"],
                    "price": float(item.get("price", 0)),
                    "quantity": quantity,
                    "note": note,
                }
            )

        return {
            "ok": True,
            "message": f"已加入订单：{item['name']} {quantity} 份。",
            "item": item,
        }

    def update_item(self, item_name: str, quantity: int) -> Dict[str, Any]:
        existing = self._find_temp_item(item_name)

        if not existing:
            return {
                "ok": False,
                "message": "临时订单里没有找到该菜品。",
            }

        if quantity <= 0:
            return {
                "ok": False,
                "message": "数量必须大于 0。",
            }

        existing["quantity"] = quantity

        return {
            "ok": True,
            "message": f"已修改为：{existing['name']} {quantity} 份。",
            "item": existing,
        }

    def update_item_note(self, item_name: str, note: str) -> Dict[str, Any]:
        existing = self._find_temp_item(item_name)

        if not existing:
            return {
                "ok": False,
                "message": "临时订单里没有找到该菜品。",
            }

        existing["note"] = note

        return {
            "ok": True,
            "message": f"已修改备注：{existing['name']}，{note}。",
            "item": existing,
        }

    def remove_item(self, item_name: str) -> Dict[str, Any]:
        idx = self._find_temp_item_index(item_name)

        if idx is None:
            return {
                "ok": False,
                "message": "临时订单里没有找到该菜品。",
            }

        removed = self.temp_order.pop(idx)

        return {
            "ok": True,
            "message": f"已删除：{removed['name']}。",
            "item": removed,
        }

    def has_items(self) -> bool:
        return len(self.temp_order) > 0

    def clear_temp_order(self) -> None:
        self.temp_order = []

    def format_menu_text(self) -> str:
        self.refresh_menu()

        items = []

        for item in self.menu_items:
            if item.get("available", True):
                category = item.get("category") or "未分类"
                items.append(f"{category}：{item.get('name')}，{item.get('price', 0)}元")

        return "；".join(items) if items else "当前没有可售菜品。"

    def format_order_summary(self) -> str:
        if not self.temp_order:
            return "当前临时订单为空。"

        total = 0.0
        lines = []

        for item in self.temp_order:
            subtotal = float(item.get("price", 0)) * int(item.get("quantity", 0))
            total += subtotal
            note = item.get("note", "")
            note_part = f"，备注：{note}" if note else ""
            lines.append(f"{item['name']} x {item['quantity']}，小计 {subtotal:.2f} 元{note_part}")

        return "；".join(lines) + f"。总计 {total:.2f} 元。"

    def get_temp_order_items(self) -> List[Dict[str, Any]]:
        return list(self.temp_order)

    def _find_temp_item(self, item_name: str) -> Optional[Dict[str, Any]]:
        idx = self._find_temp_item_index(item_name)
        return self.temp_order[idx] if idx is not None else None

    def _find_temp_item_index(self, item_name: str) -> Optional[int]:
        item_name = (item_name or "").strip().replace(" ", "")

        for idx, item in enumerate(self.temp_order):
            item_real_name = item.get("name", "").replace(" ", "")
            if item_name in item_real_name or item_real_name in item_name:
                return idx

        matched = self.find_menu_item(item_name)

        if matched:
            matched_name = matched.get("name", "").replace(" ", "")
            for idx, item in enumerate(self.temp_order):
                item_real_name = item.get("name", "").replace(" ", "")
                if matched_name == item_real_name:
                    return idx

        return None


if __name__ == "__main__":
    print("This file is intended to be imported by voice_interaction_node.py")
